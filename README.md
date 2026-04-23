# Hyperliquid Portfolio Tracker

**Spec deliverables**
- Real-time prices for all assets via Hyperliquid WebSocket `allMids` stream
- Full asset list with 24h change percentages and price sparklines
- Wallet address input with account summary: net equity, withdrawable balance, margin usage
- Open positions showing size, entry price, mark price, and unrealized PnL

**Beyond spec**
- **Realizable PnL via L2 order book walk** - Streams the live `l2Book` feed for each open position, walks bids (long exit) or asks (short exit) to compute true VWAP exit price, slippage in dollars and percent, and realizable PnL. Updates every 100ms. Shows `Est. — shallow book` warning when the 20-level API depth is insufficient to fill the full position size.
- **Next-epoch funding projection** — computes the exact USDC amount a trader will pay or receive at the next top-of-hour funding settlement, with a live countdown timer. Distinguishes between market funding direction (Rate) and position-directional cashflow (Next funding); a long in a positive funding environment sees a green Rate but red Next funding.
- **48h funding rate sparkline** — fetches hourly settled funding history and plots it as an inline chart on the position detail screen. Chart color reflects last settled rate; Next funding color reflects predicted rate; both are semantically independent.
- **Pre-trade entry simulator** — tapping any asset on the markets screen opens a bottom sheet that reuses the entire domain layer (VwapCalculator, FundingEngine, FundingEpoch) to simulate a hypothetical entry. Enter a USDC size, choose long or short, and see estimated entry VWAP, slippage, funding cost per epoch, and liquidation price at 10x, computed from the live order books
- **Liquidation proximity bar** — visual indicator showing how far mark price has traveled from entry toward liquidation. Hidden for cross-margin positions where Hyperliquid returns null for `liquidationPx`.
- **Saved address book** — locally persisted wallet addresses with nicknames via `shared_preferences`. App boots directly into the last active wallet. Long press to rename or delete. Supports up to 10 saved wallets.
- **PnL share card** — one-tap share button on position detail captures an offscreen `RepaintBoundary` at 3x pixel ratio and opens the native iOS/Android share sheet with a branded Plutus card showing realizable PnL, entry, mark, VWAP, and slippage.

## Architecture

### Layered Architecture

```
lib/
  data/          # Transport, serialization, all Riverpod providers
  domain/        # Pure Dart business logic
  screens/       # Full-screen ConsumerStateful/ConsumerWidget compositions
  widgets/       # Reusable composable components
  theme/         # AppColors, AppTextStyles
```

**Data layer** owns everything that touches the network or disk. `HyperliquidRestClient` is a thin HTTP adapter- a single `_post` helper sends all requests to `/info` and returns decoded JSON. Each public method handles one endpoint and maps the raw response to a domain model. `HyperliquidWsClient` owns two `async*` generator streams (`_rawStreamMarkPrices`, `_rawStreamOrderBook`), each with an unconditional reconnect loop on socket drop and a 3-second backoff. `AddressBookService` is a `shared_preferences` adapter, all reads and writes are wrapped in silent try/catch so address book failures are never surfaced to the UI. All Riverpod providers live in a single `providers.dart` 

**Domain layer** contains four pure-Dart classes with zero Flutter dependencies. `VwapCalculator` walks order book levels to compute VWAP exit price, realizable PnL, and slippage. It handles insufficient liquidity by pricing the unfilled remainder at the worst available level. `FundingEngine` aggregates per-position funding cashflows using the Hyperliquid convention (rate × notional × directional sign). `FundingEpoch` computes seconds to the next UTC top-of-hour boundary and formats next-epoch cashflows for display. `AddressBook`/`SavedWallet` are pure value types with `toJson`/`fromJson`. The domain layer is deliberately unaware of Riverpod, making the calculators directly testable and reusable. The entry simulator sheet reuses `VwapCalculator` directly, passing an inverted `PositionSide` to walk the entry side of the book.

**Presentation layer** splits into screens (full-page owners of provider watches and layout) and widgets (stateless or minimally stateful components that receive already-resolved values as parameters). `PositionCard` and `ShareCard` are fully stateless, they accept a `Position` and optional `VwapResult` and have no provider dependencies.

---

### State Management

The provider graph uses five distinct provider types, each matched to its data characteristic:

| Provider | Used for | Instances |
|---|---|---|
| `Provider` | Singleton service objects | `restClientProvider`, `wsClientProvider`, `addressBookServiceProvider` |
| `StateProvider<String?>` | Active wallet address | `addressProvider` |
| `StreamProvider` / `StreamProvider.family` | Live WebSocket feeds | `markPricesProvider`, `orderBookProvider(coin)`, `epochCountdownProvider` |
| `FutureProvider` / `FutureProvider.family` | REST snapshots | `accountSummaryProvider(addr)`, `positionsProvider(addr)`, `dayCandlesProvider(coin)`, `fundingHistoryProvider(coin)`, and four global providers |
| `Provider.family<VwapResult?, (Position, OrderBook)>` | Synchronous derived computation | `vwapResultProvider` |
| `StateNotifierProvider` | Mutable local state | `savedWalletsProvider` |

All REST `FutureProvider` implementations use `ref.read` (not `ref.watch`) on the REST client, which means Riverpod caches the result for the provider's lifetime and does not re-execute on unrelated state changes. Explicit cache invalidation is used in two places: `_invalidateRestProviders` is called when the user submits a new address (immediate) and by a 30-second `Timer.periodic` in `PortfolioScreen.initState` (background refresh). This keeps the portfolio data fresh without coupling it to the WebSocket tick rate.

`fundingCashflowProvider` `await`s `positionsProvider(address).future` then calls `ref.read(markPricesProvider).valueOrNull` to snapshot the current live mark prices for notional calculation. This gives accurate notional values without subscribing the cashflow computation to the 500ms price stream.

`epochCountdownProvider` is a `Stream.periodic(Duration(seconds: 1), ...)` wrapping the pure `FundingEpoch.formattedCountdown()` calculation. No network call nor state, the stream is Riverpod's lifecycle-managed clock.

`SavedWalletsNotifier` (`StateNotifierProvider`) wraps `AddressBookService` and maintains an in-memory list that shadows the `shared_preferences` store. Mutations write through to disk then re-read the full list to guarantee consistency. The `mounted` guard on all async state mutations prevents writes after disposal.

---

### Performance & Data Flow

**Stream throttling.** Both WebSocket streams are throttled at the client layer using rxdart's `throttleTime` before they reach any provider:

- `allMids` → 500ms (`streamMarkPrices`)
- `l2Book` → 100ms (`streamOrderBook`)

Throttling happens in `HyperliquidWsClient` before the data enters Riverpod, so no provider or widget ever sees a higher-frequency signal than these ceilings regardless of how many widgets watch the stream.

**Granular widget rebuilds.** The positions list in `PortfolioScreen` wraps each position in a private `_LivePositionCard` (`ConsumerWidget`). Each card independently watches `markPricesProvider` and `orderBookProvider(coin)`, so a price tick for BTC triggers a rebuild only in the BTC card, not the ETH card and not the parent screen. The same pattern is applied in `MarketsScreen`: each row is wrapped in an inline `Consumer` inside `ListView.builder`, scoping mark price observations to individual row widgets.

**Synchronous VWAP derivation.** `vwapResultProvider` is a synchronous `Provider.family` that recomputes on each build when its `(Position, OrderBook)` arguments change. Because it is synchronous and has no async gap, it contributes zero frames of latency to the card update path: mark price ticks -> order book snapshot -> VWAP calculation -> widget paint all happen within a single frame.

**Session-scoped REST caching.** `dayCandlesProvider` and `fundingHistoryProvider` use `ref.read` internally, which means each coin's candle and funding history data is fetched exactly once per app session and held in Riverpod's cache. Ten asset rows in the markets list do not produce ten recurring requests on each price tick.

**Offscreen rendering for share capture.** `PositionDetailScreen` keeps an offscreen `RepaintBoundary` (positioned at `left: -9999`) permanently in the widget tree, wrapped in a `Material` ancestor to satisfy Flutter's text rendering requirements. Because it is always rendered, `RenderRepaintBoundary.toImage(pixelRatio: 3.0)` is synchronous at capture time. No layout or paint delay when the share button is tapped.

## Known Limitations

- **Book depth:** Hyperliquid's API returns at most 20 levels per side regardless of endpoint or parameters. For large positions (700+ BTC), the full position cannot be filled from 20 levels and the VWAP is estimated by pricing the unfilled remainder at the worst available bid. The `Est. — shallow book` warning is shown in these cases. With exchange-provided historical depth data this could be improved significantly.

- **Cross-margin liquidation:** Hyperliquid returns `null` for `liquidationPx` on cross-margin positions because the entire account equity backs all positions rather than per-position isolated margin. The liquidation section is hidden for these positions rather than showing $0.00.

- **Funding rate projection:** The next-epoch projection is based on a single predicted rate from `metaAndAssetCtxs`. Hyperliquid does not expose a term structure of future funding rates, so the projection cannot show a curve.

- **Position data staleness window** Positions are fetched on address sumbit and re-fetched by a Timer.periodic every 30 seconds, a trade open/closed within that window won;t appear until the next poll cycle 

- **One WebSocket per open position** streamOrderBook opens a dedicated WebSocket connection per asset. With five open positions you have five concurrent connections. OK at low counts, won't scale to a huge portfolio

## If I Had More Time

- **Real-time position updates via userEvents** - HL exposes a `userEvents` WebSocket subscription that pushes fills and liquidations as they happen, implementing this would eliminate the staleness window
- **Multiplexed WebSocket with subscription manager** - A single connection with clientside subscription registry would replace the current pattern and scale cleanly to larger portoflio sizes
- **Zero-allocation Rust FFI Engine** - handling thousands of L2 tick updates per second in Dart will eventually theoretically trigger garbage collection pauses, dropping UI frames during peak volatility- I'd move the order book state management and VWAP calculations into a memory-safe, pre-allocated Rust shared library, exposing the calculated values to Flutter via dart:ffi and completely shielding the main isolate from high-frequency parsing overhead
- **Backtest the VWAP calculator** against historical L2 snapshots to quantify how accurate the 20-level estimate is for various position sizes
- **Trade history** using `userFills` endpoint
- **Funding rate term structure** if Hyperliquid ever exposes predicted rates beyond the next epoch, would make the sparkline projection more meaningful
- **Push notifications** for liquidation proximity threshold breaches, requires a lightweight backend but the domain logic is already in place
- **Multi-position portfolio Greeks** — net delta, total notional, aggregate liquidation scenario across all positions

## Built By

Adam Khadre — [plutus-adam-take-home](https://github.com/adamkhadre/plutus-adam-take-home)
