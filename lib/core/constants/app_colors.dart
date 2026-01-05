import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===============================
  // BRAND
  // ===============================
  static const Color primary = Color(0xFF0F6B4A);
  static const Color secondary = Color(0xFFC9A227);
  static const Color accent = secondary;

  // ===============================
  // BACKGROUNDS
  // ===============================
  static const Color bg = Color(0xFFF8F9FA);
  static const Color bgDark = Color(0xFF0B1220);

  // ===============================
  // CARDS
  // ===============================
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF111827);

  // ===============================
  // BORDERS
  // ===============================
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF1F2937);

  // ===============================
  // TEXT — LIGHT MODE
  // ===============================
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF6B7280);

  // ===============================
  // TEXT — DARK MODE
  // ===============================
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textMutedDark = Color(0xFF9CA3AF);

  // ===============================
  // STATUS
  // ===============================
  static const Color error = Color(0xFFB91C1C);
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFD97706);

  // ===============================
  // STATUS — DARK MODE
  // ===============================
  static const Color errorDark = Color(0xFFEF4444);
  static const Color successDark = Color(0xFF22C55E);
  static const Color warningDark = Color(0xFFF59E0B);

  // ===============================
  // CATEGORY ACCENTS
  // ===============================
  static const Color breakingNews = Color(0xFFDC2626);
  static const Color health = Color(0xFF16A34A);
  static const Color education = Color(0xFF2563EB);
  static const Color economy = Color(0xFF7C3AED);
  static const Color announcements = Color(0xFF0891B2);

  // ===============================
  // BACKWARD-COMPATIBILITY ALIASES
  // (prevents breaking older widgets)
  // ===============================
  static const Color text = textPrimary;
  static const Color textDark = textPrimaryDark;
}
