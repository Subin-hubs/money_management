import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Base ─────────────────────────────────────
  static const Color background   = Color(0xFFF5F6FA);
  static const Color surface      = Colors.white;
  static const Color textPrimary  = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color divider      = Color(0xFFF0F0F0);

  // ── Transaction types ────────────────────────
  static const Color expense      = Color(0xFFFF6B6B);
  static const Color expenseLight = Color(0xFFFFF0F0);
  static const Color income       = Color(0xFF26D07C);
  static const Color incomeLight  = Color(0xFFEDFFF6);

  // ── Category palette ─────────────────────────
  static const Color catFood          = Color(0xFFFF6B6B);
  static const Color catTransport     = Color(0xFF4ECDC4);
  static const Color catTuition       = Color(0xFF6C63FF);
  static const Color catShopping      = Color(0xFFFF9F43);
  static const Color catEntertainment = Color(0xFFFF78C4);
  static const Color catSalary        = Color(0xFF26C6DA);
  static const Color catFreelance     = Color(0xFF66BB6A);
  static const Color catInvestment    = Color(0xFFAB47BC);
  static const Color catGift          = Color(0xFFFF9F43);
  static const Color catOthers        = Color(0xFF8D8D8D);

  // ── Accent ───────────────────────────────────
  static const Color purple = Color(0xFF6C63FF);

  // ── Shadow helpers ───────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> accentShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.38),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
