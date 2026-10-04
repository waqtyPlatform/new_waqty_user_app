import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/features/account/language/data/models/language_option_model.dart';
import 'package:waqty_user_application/features/account/language/logic/language_cubit.dart';
import 'package:waqty_user_application/features/account/language/ui/widgets/language_header.dart';
import 'package:waqty_user_application/features/account/language/ui/widgets/language_info_note.dart';
import 'package:waqty_user_application/features/account/language/ui/widgets/language_option_card.dart';

class LanguageContent extends StatelessWidget {
  const LanguageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = LanguageCubit.get(context);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 130.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LanguageHeader(),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: Column(
                children: [
                  LanguageOptionCard(
                    option: LanguageOptionModel(
                      title: context.tr('language.arabicTitle'),
                      subtitle: context.tr('language.arabicSubtitle'),
                      label: context.tr('language.arabicLabel'),
                      languageCode: 'ar',
                    ),
                    selected: cubit.selectedLanguageCode == 'ar',
                    onTap: () => cubit.changeLanguage(context, 'ar'),
                  ),
                  SizedBox(height: 8.h),
                  LanguageOptionCard(
                    option: LanguageOptionModel(
                      title: context.tr('language.englishTitle'),
                      subtitle: context.tr('language.englishSubtitle'),
                      label: context.tr('language.englishLabel'),
                      languageCode: 'en',
                    ),
                    selected: cubit.selectedLanguageCode == 'en',
                    onTap: () => cubit.changeLanguage(context, 'en'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: const LanguageInfoNote(),
            ),
          ],
        ),
      ),
    );
  }
}
