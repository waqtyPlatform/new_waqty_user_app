import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/account/language/logic/language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit({required String initialLanguageCode})
    : selectedLanguageCode = initialLanguageCode,
      super(LanguageInitialState());

  String selectedLanguageCode;

  Future<void> changeLanguage(BuildContext context, String languageCode) async {
    if (selectedLanguageCode == languageCode) return;
    selectedLanguageCode = languageCode;
    final locale = languageCode == 'en'
        ? const Locale('en', 'US')
        : const Locale('ar', 'EG');
    await context.setLocale(locale);
    emit(LanguageChangedState(languageCode: languageCode));
  }

  void markSaved() {
    emit(LanguageSavedState());
  }

  static LanguageCubit get(context) => BlocProvider.of(context);
}
