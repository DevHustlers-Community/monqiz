import 'package:flutter/material.dart';

/// MONQIZ Design System Colors & Semantic Tokens
/// Directly mapped 1:1 from `code.html` (v2.0 Figma Handoff)
abstract final class AppColors {
  // --- Category 1: Brand & Emergency Reds ---
  /// Primary Red: Main buttons, brand, emergency icons (#C62828)
  static const Color primary = Color(0xFFC62828);

  /// Dark Red: Active/pressed state, urgent banner (#8E1717)
  static const Color primaryDark = Color(0xFF8E1717);

  /// Accent Red: Countdown badges, rare blood calls (#EF4444)
  static const Color primaryLight = Color(0xFFEF4444);
  static const Color accentRed = Color(0xFFEF4444);

  /// Red Surface / Soft Tint: Alert backgrounds, blood group badges (#FEE2E2)
  static const Color primarySoft = Color(0xFFFEE2E2);
  static const Color primarySurface = Color(0xFFFEE2E2);

  /// Blood Wash / Ultra Soft Tint: Active critical case card backgrounds (#FFF5F5)
  static const Color primaryTint = Color(0xFFFFF5F5);

  // --- Category 2: Semantic & Healthcare Indicators ---
  /// Success Green: Clinical verification, MOH accredited, donation ready (#16835D)
  static const Color success = Color(0xFF16835D);
  static const Color medicalGreen = Color(0xFF16835D);

  /// Success Green Soft: Verification pill background (#DCFCE7)
  static const Color successSoft = Color(0xFFDCFCE7);

  /// Warning Amber: Rest interval remaining, pending review, alerts (#D97706)
  static const Color warning = Color(0xFFD97706);
  static const Color medicalAmber = Color(0xFFD97706);

  /// Warning Amber Soft: Rest interval pill background (#FEF3C7)
  static const Color warningSoft = Color(0xFFFEF3C7);

  /// Medical Info Blue: Maps, directions, clinical articles, devices (#0284C7)
  static const Color info = Color(0xFF0284C7);
  static const Color medicalBlue = Color(0xFF0284C7);

  /// Medical Info Blue Soft: Identity/biometrics pill background (#E0F2FE)
  static const Color infoSoft = Color(0xFFE0F2FE);

  /// MOH Teal Tint: Ministry of Health accreditation (#0F766E)
  static const Color mohTeal = Color(0xFF0F766E);
  static const Color mohTealSoft = Color(0xFFCCFBF1);

  // --- Category 3: Surfaces, Backgrounds & Borders ---
  /// Page Background: Soft, eye-pleasing background (#F8FAFC)
  static const Color surfaceBase = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF8FAFC);

  /// Card Surface: Pure white card background (#FFFFFF)
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  /// Surface Subtle: Alternate neutral card/input background (#F1F5F9)
  static const Color surfaceSubtle = Color(0xFFF1F5F9);

  /// Standard Border: Field borders, card dividers (#E2E8F0)
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  static const Color semanticSuccess = success;
  static const Color semanticWarning = warning;
  static const Color semanticError = primary;

  // --- Category 4: Typography & Neutrals ---
  /// Dark Neutral / Slate-800: Headings and high-contrast text (#1F2937)
  static const Color textPrimary = Color(0xFF1F2937);

  /// Typography Muted / Slate-500: Secondary text, dates, notes (#64748B)
  static const Color textSecondary = Color(0xFF64748B);

  /// Typography Subtle / Slate-400: Placeholders, timestamps, borders (#94A3B8)
  static const Color textSubtle = Color(0xFF94A3B8);

  /// Slate 900: Hotline button background & dark surfaces (#0F172A)
  static const Color slate900 = Color(0xFF0F172A);

  /// Slate 800 (#1E293B)
  static const Color slate800 = Color(0xFF1E293B);

  /// Slate 700 (#334155)
  static const Color slate700 = Color(0xFF334155);
}
