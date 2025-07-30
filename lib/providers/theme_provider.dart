import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isYoungerGroup = true;

  bool get isYoungerGroup => _isYoungerGroup;

  void setAgeGroup(int age) {
    _isYoungerGroup = age >= 5 && age <= 7;
    notifyListeners();
  }

  ThemeData get theme {
    if (_isYoungerGroup) {
      return _youngerGroupTheme;
    } else {
      return _olderGroupTheme;
    }
  }

  static final ThemeData _youngerGroupTheme = ThemeData(
    primaryColor: const Color(0xFF6B9DFF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6B9DFF),
      secondary: Color(0xFFFF8A80),
      surface: Color(0xFFF5F9FF),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F9FF),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D3748),
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D3748),
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        color: const Color(0xFF4A5568),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B9DFF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF6B9DFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF6B9DFF), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF6B9DFF), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );

  static final ThemeData _olderGroupTheme = ThemeData(
    primaryColor: const Color(0xFF5C6BC0),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF5C6BC0),
      secondary: Color(0xFFFF7043),
      surface: Color(0xFFFAFAFA),
    ),
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A237E),
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A237E),
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: const Color(0xFF424242),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5C6BC0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );
} 