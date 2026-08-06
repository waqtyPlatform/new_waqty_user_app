import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// مبدّل اللغة — قرص بيتزحلق بين «ع» و«EN».
///
/// كان بيبني نفس النص مرتين في `Row` والاتنين بنفس اللون في الحالتين
/// (`x ? green : green`)، يعني الشرط مكانش بيعمل حاجة والحرف اللي تحت القرص
/// كان بيختفي فيه.
///
/// دلوقتي حرف واحد لكل جنب وكل واحد لونه بيتحسب من مكان القرص فعلاً، والمدة
/// من `AppMotion` — القديمة كانت `Duration(microseconds: 600)` (ميكرو مش
/// ميلي)، يعني **٠٫٦ من الألف من الثانية**: الحركة كانت مش موجودة عمليًا.
class ChangeLanguageIconWidget extends StatelessWidget {
  const ChangeLanguageIconWidget({super.key});

  static const Locale _ar = Locale('ar', 'EG');
  static const Locale _en = Locale('en', 'US');

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';

    return Semantics(
      button: true,
      label: isEnglish ? 'التبديل للعربية' : 'Switch to English',
      child: InkWell(
        onTap: () => context.setLocale(isEnglish ? _ar : _en),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          width: 64.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppSemanticColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: AppMotion.base,
                curve: AppMotion.standard,
                alignment: isEnglish
                    ? AlignmentDirectional.centerStart
                    : AlignmentDirectional.centerEnd,
                child: Container(
                  width: 28.w,
                  height: 28.h,
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: AppSemanticColors.textOnAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(child: _label('EN', isOnDisc: isEnglish)),
                  Expanded(child: _label('ع', isOnDisc: !isEnglish)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// اللي فوق القرص بياخد لون اللمسة، واللي على الخلفية الخضرا بياخد
  /// [AppSemanticColors.textOnAccent].
  Widget _label(String text, {required bool isOnDisc}) => Center(
    child: Text(
      text,
      style: AppTextStyles.overline.copyWith(
        color: isOnDisc
            ? AppSemanticColors.accent
            : AppSemanticColors.textOnAccent,
      ),
    ),
  );
}
