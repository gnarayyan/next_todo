import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadThemeSettings extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class SetLanguage extends ThemeEvent {
  final String languageCode;

  const SetLanguage(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}
