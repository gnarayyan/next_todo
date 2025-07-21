import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;
  final String selectedLanguage;

  const ThemeState({this.isDarkMode = false, this.selectedLanguage = 'en'});

  ThemeState copyWith({bool? isDarkMode, String? selectedLanguage}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 6,
      shape: CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 6,
      shape: CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  Color getPriorityColor(String priority, {bool? isDark}) {
    final bool darkMode = isDark ?? isDarkMode;
    switch (priority.toLowerCase()) {
      case 'high':
        return darkMode ? Colors.red.shade300 : Colors.red.shade600;
      case 'medium':
        return darkMode ? Colors.orange.shade300 : Colors.orange.shade600;
      case 'low':
        return darkMode ? Colors.green.shade300 : Colors.green.shade600;
      default:
        return darkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    }
  }

  LinearGradient get primaryGradient => LinearGradient(
    colors: isDarkMode
        ? [
            const Color(0xFF6750A4).withAlpha((0.8 * 255).toInt()),
            const Color(0xFF9C27B0).withAlpha((0.8 * 255).toInt()),
          ]
        : [const Color(0xFF6750A4), const Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get backgroundGradient => LinearGradient(
    colors: isDarkMode
        ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
        : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  List<Object> get props => [isDarkMode, selectedLanguage];
}
