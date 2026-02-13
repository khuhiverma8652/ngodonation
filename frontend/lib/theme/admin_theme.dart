import 'package:flutter/material.dart';

class AdminTheme {
  static const primary = Color(0xFF6200EE);
  static const secondary = Color(0xFF3700B3);
  static const background = Color(0xFFF5F6FA);

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primary, secondary],
  );

  static BoxDecoration cardDecoration(Color color) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
