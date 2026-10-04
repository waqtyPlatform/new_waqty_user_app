abstract class LanguageState {}

class LanguageInitialState extends LanguageState {}

class LanguageChangedState extends LanguageState {
  final String languageCode;

  LanguageChangedState({required this.languageCode});
}

class LanguageSavedState extends LanguageState {}
