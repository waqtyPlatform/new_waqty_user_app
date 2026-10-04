import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/account/language/logic/language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit({required String initialLanguageCode})
    : selectedLanguageCode = initialLanguageCode,
      super(LanguageInitialState());

  String selectedLanguageCode;

  void changeLanguage(String languageCode) {
    if (selectedLanguageCode == languageCode) return;
    selectedLanguageCode = languageCode;
    emit(LanguageChangedState(languageCode: languageCode));
  }

  void markSaved() {
    emit(LanguageSavedState());
  }

  static LanguageCubit get(context) => BlocProvider.of(context);
}
