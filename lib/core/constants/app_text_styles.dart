import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static Color get _text =>
      Get.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;
  static Color get _muted =>
      Get.isDarkMode ? AppColors.textMutedDark : AppColors.textMuted;

  static TextStyle get appBar => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _text,
      );

  static TextStyle get headline => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _text,
        letterSpacing: -0.4,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _text,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _text,
        height: 1.45,
      );

  static TextStyle get bodyMuted => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _muted,
      );

  static TextStyle get link => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _text,
      );

  static TextStyle get tileTitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _text,
      );

  static TextStyle get mutedCaps => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: _muted,
        letterSpacing: 1.0,
      );

  static TextStyle get chip => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _text,
      );

  static TextStyle get chipActive => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );

  static TextTheme get textTheme =>
      GoogleFonts.interTextTheme().copyWith(
        headlineMedium: headline,
        titleLarge: sectionTitle,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: bodyMuted,
        labelLarge: button,
      );
}
