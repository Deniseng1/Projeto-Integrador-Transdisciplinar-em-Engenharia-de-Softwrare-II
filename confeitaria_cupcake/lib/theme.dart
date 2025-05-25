import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tema inspirado em confeitarias francesas
class AppTheme {
  // Cores principais
  static const Color primaryColor = Color(0xFFEF5DA8); // Rosa pastel
  static const Color secondaryColor = Color(0xFF9C71C7); // Lavanda suave
  static const Color accentColor = Color(0xFFF9D5E5); // Rosa claro
  static const Color backgroundColor = Color(0xFFFFF8FA); // Branco rosado
  static const Color darkBackgroundColor = Color(0xFF2E2A2E); // Marrom escuro
  
  // Cores funcionais
  static const Color successColor = Color(0xFF81C784); // Verde pastel
  static const Color warningColor = Color(0xFFF57F17); // Amarelo âmbar mais forte
  static const Color errorColor = Color(0xFFE57373); // Vermelho suave
  static const Color infoColor = Color(0xFF64B5F6); // Azul claro
  
  // Cores de texto
  static const Color textPrimaryColor = Color(0xFF5D4037); // Chocolate
  static const Color textSecondaryColor = Color(0xFF8D6E63); // Marrom claro
  static const Color textLightColor = Color(0xFFF5E3E0); // Creme
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFFFF9BD2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFFBE90D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppTheme.primaryColor,
        secondary: AppTheme.secondaryColor,
        tertiary: const Color(0xFFF2D492), // Dourado claro
        surface: AppTheme.backgroundColor,
        background: AppTheme.backgroundColor,
        error: AppTheme.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: AppTheme.textPrimaryColor,
        onSurface: AppTheme.textPrimaryColor,
        onBackground: AppTheme.textPrimaryColor,
        onError: Colors.white,
        outline: const Color(0xFFDEC2CB), // Rosa antigo suave
        surfaceTint: AppTheme.accentColor,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppTheme.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.secondaryColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppTheme.accentColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppTheme.accentColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppTheme.textSecondaryColor.withOpacity(0.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor.withOpacity(0.5),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimaryColor,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimaryColor,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimaryColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimaryColor,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimaryColor,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimaryColor,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: AppTheme.textPrimaryColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: AppTheme.textPrimaryColor,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: AppTheme.textSecondaryColor,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimaryColor,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimaryColor,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppTheme.primaryColor,
        secondary: AppTheme.secondaryColor,
        tertiary: const Color(0xFFF2D492), // Dourado claro
        surface: AppTheme.darkBackgroundColor,
        background: AppTheme.darkBackgroundColor,
        error: AppTheme.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: AppTheme.textLightColor,
        onBackground: AppTheme.textLightColor,
        onError: Colors.white,
        outline: const Color(0xFF4A404D), // Roxo escuro
        surfaceTint: AppTheme.primaryColor.withOpacity(0.2),
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTheme.darkBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.darkBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF3D353D), // Marrom escuro mais claro
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.accentColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3D353D), // Marrom escuro mais claro
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppTheme.textLightColor.withOpacity(0.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF3D353D), // Marrom escuro mais claro
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textLightColor.withOpacity(0.5),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLightColor,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLightColor,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLightColor,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.textLightColor,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.textLightColor,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.textLightColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: AppTheme.textLightColor,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textLightColor,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textLightColor,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: AppTheme.textLightColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: AppTheme.textLightColor,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: AppTheme.textLightColor.withOpacity(0.7),
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textLightColor,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textLightColor,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
          color: AppTheme.textLightColor.withOpacity(0.7),
        ),
      ),
    );