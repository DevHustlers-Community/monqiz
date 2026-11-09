import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// MONQIZ Design System Typography System & Type Scale
/// Primary Arabic Font: IBM Plex Sans Arabic
/// Primary Latin Font: Inter
/// Monospace Font: Fira Code
/// Display Accent: Space Grotesk
abstract final class AppTypography {
  static const String arabicFontFamily = 'IBM Plex Sans Arabic';
  static const String latinFontFamily = 'Inter';
  static const String monoFontFamily = 'Fira Code';
  static const String displayFontFamily = 'Space Grotesk';

  /// Display / Hero: 36px (2.25rem), Line Height: 44px, Weight: Bold 800
  static TextStyle displayHero({Color color = AppColors.textPrimary}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 36,
      height: 44 / 36,
      fontWeight: FontWeight.w800,
      color: color,
    );
  }

  /// Heading 1 / H1: 30px (1.875rem), Line Height: 38px, Weight: Bold 700
  static TextStyle heading1({Color color = AppColors.textPrimary}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 30,
      height: 38 / 30,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  /// Heading 2 / H2: 24px (1.5rem), Line Height: 32px, Weight: SemiBold 600
  static TextStyle heading2({Color color = AppColors.textPrimary}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Heading 3 / H3: 20px (1.25rem), Line Height: 28px, Weight: SemiBold 600
  static TextStyle heading3({Color color = AppColors.textPrimary}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Heading 4 / H4: 16px (1.0rem), Line Height: 24px, Weight: Medium 500
  static TextStyle heading4({Color color = AppColors.textPrimary}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Body Large: 16px (1.0rem), Line Height: 26px, Weight: Regular 400
  static TextStyle bodyLarge({Color color = AppColors.textPrimary}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 16,
      height: 26 / 16,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  /// Body Base / Regular: 14px (0.875rem), Line Height: 22px, Weight: Regular 400
  static TextStyle bodyBase({Color color = AppColors.textPrimary}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 14,
      height: 22 / 14,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  /// Body Small / Caption: 12px (0.75rem), Line Height: 18px, Weight: Regular 400
  static TextStyle bodySmall({Color color = AppColors.textSecondary}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 12,
      height: 18 / 12,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  /// Button / Label: 14px (0.875rem), Line Height: 20px, Weight: SemiBold 600
  static TextStyle buttonLabel({Color color = Colors.white}) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Monospace / Data Tag: 12px, Line Height: 16px, Weight: Medium 500
  static TextStyle codeTag({Color color = AppColors.textPrimary}) {
    return GoogleFonts.firaCode(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Latin / English Font styling using Inter
  static TextStyle latin({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Creates a complete Material TextTheme configured with MONQIZ typography tokens
  static TextTheme createTextTheme() {
    return TextTheme(
      displayLarge: displayHero(),
      headlineLarge: heading1(),
      headlineMedium: heading2(),
      headlineSmall: heading3(),
      titleMedium: heading4(),
      bodyLarge: bodyLarge(),
      bodyMedium: bodyBase(),
      bodySmall: bodySmall(),
      labelLarge: buttonLabel(),
    );
  }

  // --- Static Convenience Methods for Material / Flutter UI ---
  static TextStyle headlineLarge({Color color = AppColors.textPrimary}) => heading1(color: color);
  static TextStyle headlineMedium({Color color = AppColors.textPrimary}) => heading2(color: color);
  static TextStyle headlineSmall({Color color = AppColors.textPrimary}) => heading3(color: color);
  static TextStyle titleLarge({Color color = AppColors.textPrimary}) => heading2(color: color);
  static TextStyle titleMedium({Color color = AppColors.textPrimary}) => heading3(color: color);
  static TextStyle titleSmall({Color color = AppColors.textPrimary}) => heading4(color: color);
  static TextStyle bodyLargeText({Color color = AppColors.textPrimary}) => bodyLarge(color: color);
  static TextStyle bodyMedium({Color color = AppColors.textPrimary}) => bodyBase(color: color);
  static TextStyle bodySmallText({Color color = AppColors.textSecondary}) => bodySmall(color: color);
  static TextStyle caption({Color color = AppColors.textSecondary}) => bodySmall(color: color);
  static TextStyle labelLarge({Color color = Colors.white}) => buttonLabel(color: color);
  static TextStyle labelMedium({Color color = Colors.white}) => buttonLabel(color: color);
  static TextStyle labelSmall({Color color = AppColors.textSecondary}) => bodySmall(color: color);
}
