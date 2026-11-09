import 'package:flutter/material.dart';

/// MONQIZ Design System Spacing, Radius, and Shadows
/// Mathematical 4px Base Grid
abstract final class AppSpacing {
  // --- 4px Base Spacing Scale ---
  /// 4px (0.25rem): Icon gaps inside small badges
  static const double space1 = 4.0;

  /// 8px (0.5rem): Button gaps, chips, input small padding
  static const double space2 = 8.0;

  /// 12px (0.75rem): Inner card spacing
  static const double space3 = 12.0;

  /// 16px (1.0rem): Standard mobile gutter & standard padding
  static const double space4 = 16.0;

  /// 20px (1.25rem): Medium spacing
  static const double space5 = 20.0;

  /// 24px (1.5rem): Standard card padding
  static const double space6 = 24.0;

  /// 32px (2.0rem): Spacing between consecutive card groups
  static const double space8 = 32.0;

  /// 48px (3.0rem): Vertical spacing between mobile sections & button height
  static const double space12 = 48.0;

  /// 52px: Primary Mobile CTA button height
  static const double buttonHeightCta = 52.0;

  /// 48px: Standard button & form control height
  static const double controlHeight = 48.0;

  /// 64px (4.0rem): Major section spacing
  static const double space16 = 64.0;

  // --- Border Radii Tokens ---
  /// 4px: Small tags, fine details
  static const double radiusSm = 4.0;
  static const double radiusSmall = 4.0;
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);

  /// 8px (rounded-lg): Inputs, small badges, dropdowns
  static const double radiusMd = 8.0;
  static const double radiusMedium = 8.0;
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  /// 12px (rounded-xl): Buttons, compact donation cards
  static const double radiusXl = 12.0;
  static const double radiusLarge = 12.0;
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);

  /// 16px (rounded-2xl): Case & hospital primary cards
  static const double radius2Xl = 16.0;
  static final BorderRadius borderRadius2Xl = BorderRadius.circular(radius2Xl);

  /// 24px (rounded-3xl): Large containers, Hero sections
  static const double radius3Xl = 24.0;
  static final BorderRadius borderRadius3Xl = BorderRadius.circular(radius3Xl);

  /// 9999px (rounded-full): Pills, filter chips, circular badges
  static const double radiusFull = 9999.0;
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // --- Elevation & Shadows Tokens ---
  /// Shadow SM: 0 1px 2px rgba(0, 0, 0, 0.05) - Static cards
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Shadow MD: 0 4px 6px rgba(0, 0, 0, 0.07) - Hover/raised state
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x12000000),
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
  ];

  /// Red Glow Shadow: 0 10px 15px rgba(198, 40, 40, 0.2) - Emergency CTA
  static const List<BoxShadow> shadowRedGlow = [
    BoxShadow(
      color: Color(0x33C62828),
      offset: Offset(0, 10),
      blurRadius: 15,
    ),
  ];
}
