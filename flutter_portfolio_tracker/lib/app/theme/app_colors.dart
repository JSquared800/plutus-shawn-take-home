import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const bgPrimary = Color(0xFF112024);
  static const bgSecondary = Color(0xFF0F2E29);
  static const bgDeep = Color(0xFF061412);
  static const bgSurface = Color(0xFF0A1F1B);

  // ── Borders ───────────────────────────────────────────────────────────────
  static final borderSubtle = const Color(0xFF97FFE4).withValues(alpha: 0.10);
  static final borderStrong = const Color(0xFF97FFE4).withValues(alpha: 0.18);
  static final borderCard = const Color(0xFF97FFE4).withValues(alpha: 0.14);

  // ── Brand / Accents ───────────────────────────────────────────────────────
  static const accent = Color(0xFF97FFE4);
  static const blueInfo = Color(0xFF01A2D5);
  static const warning = Color(0xFFFBBF24);
  static const negative = Color(0xFFC04B32);
  static const negativeLight = Color(0xFFF87171);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF9BA3A6);
  static const textOnAccent = Color(0xFF061412);

  // ── Semantic convenience ──────────────────────────────────────────────────
  static const positive = accent;
  static const liveDot = accent;

  // ── Asset icon palette ────────────────────────────────────────────────────
  static const btcBg = Color(0x1FFBBF24);
  static const btcFg = Color(0xFFFBBF24);
  static const btcBdr = Color(0x33FBBF24);
  static const ethBg = Color(0x1F6366F1);
  static const ethFg = Color(0xFF818CF8);
  static const ethBdr = Color(0x336366F1);
  static const solBg = Color(0x1497FFE4);
  static const solFg = accent;
  static final solBdr = const Color(0xFF97FFE4).withValues(alpha: 0.20);
  static const arbBg = Color(0x1F01A2D5);
  static const arbFg = blueInfo;
  static const arbBdr = Color(0x3301A2D5);
  static const genericIconBg = Color(0x1F9BA3A6);
  static const genericIconFg = textMuted;
  static const genericIconBdr = Color(0x339BA3A6);
}
