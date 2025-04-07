import 'package:flutter/material.dart';

/// App colors and gradients used throughout the application
class AppColors {
  // Primary colors
  static const Color primaryDark = Color(0xFF4A148C); // deep purple 900
  static const Color primary = Color(0xFF673AB7); // deep purple 500
  static const Color primaryLight = Color(0xFFD1C4E9); // deep purple 100

  // Text colors
  static const Color textDark = Color(0xFF212121); // grey 900
  static const Color textMedium = Color(0xFF757575); // grey 600
  static const Color textLight = Color(0xFFFFFFFF); // white

  // Background colors
  static const Color bgLight = Color(0xFFF9F9F9); // very light grey
  static const Color bgWhite = Color(0xFFFFFFFF); // white
  static const Color bgSurface = Color(0xFFF2F2F2); // surface background
  static const Color bgCard = Color(0xFFFFFFFF); // card background

  // UI element colors
  static const Color border = Color(0xFFE0E0E0); // border color
  static const Color divider = Color(0xFFEEEEEE); // divider color
  static const Color hover = Color(0xFFF0F0F0); // hover state color

  // Accent colors
  static const Color accent1 = Color(0xFF2196F3); // blue
  static const Color accent2 = Color(0xFF4CAF50); // green for success
  static const Color accent3 = Color(0xFFFFC107); // amber for warnings
  static const Color accent4 = Color(0xFFF44336); // red for errors

  // Status colors
  static const Color success = Color(0xFF4CAF50); // green for success
  static const Color warning = Color(0xFFFFC107); // amber for warnings
  static const Color danger = Color(0xFFF44336); // red for errors/danger

  // Desktop-specific UI colors
  static const Color sidebarBg = Color(0xFF2C2C2C); // dark sidebar
  static const Color sidebarText = Color(0xFFE0E0E0); // sidebar text
  static const Color sidebarHover = Color(0xFF3D3D3D); // sidebar hover
  static const Color sidebarSelected = Color(0xFF673AB7); // selected item

  // Gradient definitions
  static LinearGradient get sidebarGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF212121), // darker color
      const Color(0xFF303030), // slightly lighter
    ],
  );

  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgLight, bgWhite, bgLight.withValues(alpha: .7)],
  );

  static LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  // Rainbow shimmer effect gradient for buttons
  static LinearGradient rainbowGradient(double rotation) => LinearGradient(
    colors: const [
      Color(0xFF9C27B0), // purple
      Color(0xFF673AB7), // deep purple
      Color(0xFF3F51B5), // indigo
      Color(0xFF2196F3), // blue
      Color(0xFF03A9F4), // light blue
      Color(0xFF00BCD4), // cyan
      Color(0xFF009688), // teal
      Color(0xFF4CAF50), // green
      Color(0xFF8BC34A), // light green
      Color(0xFFCDDC39), // lime
      Color(0xFFFFEB3B), // yellow
      Color(0xFFFFC107), // amber
      Color(0xFFFF9800), // orange
      Color(0xFFFF5722), // deep orange
      Color(0xFFF44336), // red
      Color(0xFF9C27B0), // back to purple
    ],
    stops: const [
      0.0,
      0.0625,
      0.125,
      0.1875,
      0.25,
      0.3125,
      0.375,
      0.4375,
      0.5,
      0.5625,
      0.625,
      0.6875,
      0.75,
      0.8125,
      0.875,
      1.0,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(rotation),
  );

  // Shadow for elevation effect
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Deeper shadow for elevated cards
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .10),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: .05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // Slight shadow for subtle elevation
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .04),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}
