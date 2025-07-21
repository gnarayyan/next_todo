import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<LoadThemeSettings>(_onLoadThemeSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<SetLanguage>(_onSetLanguage);

    // Load initial settings
    add(LoadThemeSettings());
  }

  void _onLoadThemeSettings(LoadThemeSettings event, Emitter<ThemeState> emit) {
    final isDarkMode = DatabaseService.isDarkMode;
    final selectedLanguage = DatabaseService.selectedLanguage;

    emit(
      state.copyWith(
        isDarkMode: isDarkMode,
        selectedLanguage: selectedLanguage,
      ),
    );
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newDarkMode = !state.isDarkMode;
    emit(state.copyWith(isDarkMode: newDarkMode));
    await DatabaseService.setDarkMode(newDarkMode);
  }

  void _onSetLanguage(SetLanguage event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(selectedLanguage: event.languageCode));
    await DatabaseService.setSelectedLanguage(event.languageCode);
  }
}
