import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  
  // Category Colors
  static const Color foodColor = Color(0xFFFF5252);
  static const Color medicalColor = Color(0xFF00BCD4);
  static const Color educationColor = Color(0xFF9C27B0);
  static const Color emergencyColor = Color(0xFFFF6F00);
  
  // Status Colors
  static const Color liveColor = Color(0xFFFF5252);
  static const Color upcomingColor = Color(0xFFFF9800);
  static const Color completedColor = Color(0xFF4CAF50);
  
  // Badge Colors
  static const Color beginnerBadge = Color(0xFF9E9E9E);
  static const Color helperBadge = Color(0xFF4CAF50);
  static const Color contributorBadge = Color(0xFF2196F3);
  static const Color championBadge = Color(0xFFFF9800);
  static const Color heroBadge = Color(0xFFE91E63);
  static const Color legendBadge = Color(0xFF9C27B0);
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black87;
  static const Color onSurface = Colors.black87;
  static const Color onError = Colors.white;
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient foodGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFE53935)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient medicalGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient educationGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return foodColor;
      case 'medical':
        return medicalColor;
      case 'education':
        return educationColor;
      case 'emergency':
        return emergencyColor;
      default:
        return primaryColor;
    }
  }
  
  // Get category gradient
  static LinearGradient getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return foodGradient;
      case 'medical':
        return medicalGradient;
      case 'education':
        return educationGradient;
      default:
        return primaryGradient;
    }
  }
  
  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return liveColor;
      case 'upcoming':
        return upcomingColor;
      case 'completed':
        return completedColor;
      default:
        return primaryColor;
    }
  }
  
  // Get badge color
  static Color getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'beginner':
        return beginnerBadge;
      case 'helper':
        return helperBadge;
      case 'contributor':
        return contributorBadge;
      case 'champion':
        return championBadge;
      case 'hero':
        return heroBadge;
      case 'legend':
        return legendBadge;
      default:
        return beginnerBadge;
    }
  }
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryVariant,
      secondary: secondaryColor,
      secondaryContainer: secondaryVariant,
      surface: surface,
      background: background,
      error: error,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onSurface: onSurface,
      onBackground: onBackground,
      onError: onError,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: surface,
      foregroundColor: onSurface,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryColor, width: 2),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: primaryColor,
      labelStyle: GoogleFonts.poppins(fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 8,
      backgroundColor: surface,
    ),
  );
  
  // Text Styles
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: onSurface,
  );
  
  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );
  
  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );
  
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: onSurface,
  );
  
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: onSurface,
  );
  
  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade600,
  );
  
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade500,
  );
  
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: onPrimary,
  );
}