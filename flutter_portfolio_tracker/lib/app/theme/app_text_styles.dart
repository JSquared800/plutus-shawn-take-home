import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String _font = 'Inter';

  // ── Hero value display (portfolio equity) ────────────────────────────────
  static const heroValue = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.56,
    height: 1.0,
  );

  // ── Section labels ────────────────────────────────────────────────────────
  static const sectionLabel = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  // ── Rows ─────────────────────────────────────────────────────────────────
  static const rowPrimary = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const rowSecondary = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const rowPrice = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const rowChange = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ── Chip / badge ──────────────────────────────────────────────────────────
  static const chipText = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
  );

  // ── Tab bar ───────────────────────────────────────────────────────────────
  static const tabLabel = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  // ── Asset detail ──────────────────────────────────────────────────────────
  static const assetDetailSymbol = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.22,
  );

  static const annotationBody = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.55,
  );

  // ── Trades table ──────────────────────────────────────────────────────────
  static const tradeTableHeader = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );

  static const tradeCell = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
