import 'package:flutter/material.dart';

/// App colors and gradients used throughout the application
class AppColors {
  // Primary colors
  static const Color primaryDark = Color(0xFF4A148C);  // deep purple 900
  static const Color primary = Color(0xFF673AB7);      // deep purple 500
  static const Color primaryLight = Color(0xFFD1C4E9); // deep purple 100
  
  // Text colors
  static const Color textDark = Color(0xFF212121);     // grey 900
  static const Color textMedium = Color(0xFF757575);   // grey 600
  static const Color textLight = Color(0xFFFFFFFF);    // white
  
  // Background colors
  static const Color bgLight = Color(0xFFF5F5F5);      // grey 100
  static const Color bgWhite = Color(0xFFFFFFFF);      // white
  
  // Gradient definitions
  static LinearGradient get sidebarGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDark,
      primary.withOpacity(0.9),
      const Color(0xFF512DA8),  // deep purple 700
    ],
  );
  
  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      bgLight,
      bgWhite,
      bgLight.withOpacity(0.7),
    ],
  );
  
  // Rainbow shimmer effect gradient for buttons
  static LinearGradient rainbowGradient(double rotation) => LinearGradient(
    colors: const [
      Color(0xFF9C27B0),  // purple
      Color(0xFF673AB7),  // deep purple
      Color(0xFF3F51B5),  // indigo
      Color(0xFF2196F3),  // blue
      Color(0xFF03A9F4),  // light blue
      Color(0xFF00BCD4),  // cyan
      Color(0xFF009688),  // teal
      Color(0xFF4CAF50),  // green
      Color(0xFF8BC34A),  // light green
      Color(0xFFCDDC39),  // lime
      Color(0xFFFFEB3B),  // yellow
      Color(0xFFFFC107),  // amber
      Color(0xFFFF9800),  // orange
      Color(0xFFFF5722),  // deep orange
      Color(0xFFF44336),  // red
      Color(0xFF9C27B0),  // back to purple
    ],
    stops: const [
      0.0, 0.0625, 0.125, 0.1875, 0.25, 0.3125, 0.375, 0.4375, 
      0.5, 0.5625, 0.625, 0.6875, 0.75, 0.8125, 0.875, 1.0
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(rotation),
  );
  
  // Shadow for elevation effect
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
