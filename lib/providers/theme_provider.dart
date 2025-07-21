import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';

  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;

  ThemeProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _isDarkMode = DatabaseService.isDarkMode;
    _selectedLanguage = DatabaseService.selectedLanguage;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await DatabaseService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    await DatabaseService.setSelectedLanguage(languageCode);
    notifyListeners();
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

  Color getPriorityColor(String priority, {bool isDark = false}) {
    switch (priority.toLowerCase()) {
      case 'high':
        return isDark ? Colors.red.shade300 : Colors.red.shade600;
      case 'medium':
        return isDark ? Colors.orange.shade300 : Colors.orange.shade600;
      case 'low':
        return isDark ? Colors.green.shade300 : Colors.green.shade600;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    }
  }

  LinearGradient get primaryGradient => LinearGradient(
    colors: _isDarkMode
        ? [
            const Color(0xFF6750A4).withAlpha((0.8 * 255).toInt()),
            const Color(0xFF9C27B0).withAlpha((0.8 * 255).toInt()),
          ]
        : [const Color(0xFF6750A4), const Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get backgroundGradient => LinearGradient(
    colors: _isDarkMode
        ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
        : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
