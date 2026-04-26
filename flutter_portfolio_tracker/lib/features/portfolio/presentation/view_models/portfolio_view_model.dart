import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/core/utils/address_validator.dart';
import 'package:flutter_portfolio_tracker/core/utils/sentinel.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/account_summary.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/open_position.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/repositories/portfolio_repository.dart';

class PortfolioViewState extends Equatable {
  const PortfolioViewState({
    this.loadedAddress,
    this.accountSummary,
    this.positions = const [],
    this.isSnapshotLoading = false,
    this.snapshotError,
  });

  /// The wallet address whose data is currently loaded. Null = blank state.
  final String? loadedAddress;
  final AccountSummary? accountSummary;
  final List<OpenPosition> positions;

  /// True while the clearinghouseState call is in flight.
  final bool isSnapshotLoading;

  final String? snapshotError;

  bool get hasData => accountSummary != null;

  /// True when no address has been loaded and no loading/error state is active.
  bool get isBlank =>
      !hasData && !isSnapshotLoading && snapshotError == null;

  PortfolioViewState copyWith({
    Object? loadedAddress = copyWithSentinel,
    Object? accountSummary = copyWithSentinel,
    List<OpenPosition>? positions,
    bool? isSnapshotLoading,
    Object? snapshotError = copyWithSentinel,
  }) {
    return PortfolioViewState(
      loadedAddress: loadedAddress == copyWithSentinel
          ? this.loadedAddress
          : loadedAddress as String?,
      accountSummary: accountSummary == copyWithSentinel
          ? this.accountSummary
          : accountSummary as AccountSummary?,
      positions: positions ?? this.positions,
      isSnapshotLoading: isSnapshotLoading ?? this.isSnapshotLoading,
      snapshotError: snapshotError == copyWithSentinel
          ? this.snapshotError
          : snapshotError as String?,
    );
  }

  @override
  List<Object?> get props => [
        loadedAddress,
        accountSummary,
        positions,
        isSnapshotLoading,
        snapshotError,
      ];
}

class PortfolioViewModel extends StateNotifier<PortfolioViewState> {
  PortfolioViewModel(this._repo) : super(const PortfolioViewState());

  final PortfolioRepository _repo;

  /// Validates [rawAddress] and, if valid, fetches portfolio snapshot.
  /// Sets [snapshotError] with a user-facing message on validation failure.
  Future<void> loadAddress(String rawAddress) async {
    final address = rawAddress.trim();
    if (!AddressValidator.isValid(address)) {
      state = state.copyWith(
        snapshotError: AddressValidator.errorMessage(address),
      );
      return;
    }

    state = state.copyWith(
      loadedAddress: address,
      accountSummary: null,
      positions: const [],
      isSnapshotLoading: true,
      snapshotError: null,
    );

    await _fetchSnapshot(address);
  }

  /// Re-fetches snapshot for the currently loaded address.
  /// No-op if no address is loaded.
  Future<void> refresh() async {
    final address = state.loadedAddress;
    if (address == null) return;

    state = state.copyWith(
      isSnapshotLoading: true,
      snapshotError: null,
    );

    await _fetchSnapshot(address);
  }

  /// Resets to blank state.
  void clearAddress() {
    state = const PortfolioViewState();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _fetchSnapshot(String address) async {
    final result = await _repo.fetchSnapshot(address);
    if (!mounted) return;
    result.fold(
      ok: (snapshot) => state = state.copyWith(
        accountSummary: snapshot.summary,
        positions: snapshot.positions,
        isSnapshotLoading: false,
        snapshotError: null,
      ),
      err: (failure) => state = state.copyWith(
        isSnapshotLoading: false,
        snapshotError: failure.message,
      ),
    );
  }
}
