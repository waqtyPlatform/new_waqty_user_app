import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// مبدّل اللغة في شاشة التسجيل.
///
/// ## كان قرص بيتزحلق، بقى [AppSegmentedWidget]
///
/// القديم كان `Container` أخضر جواه `Stack` و`AnimatedAlign` بقرص أبيض —
/// ٤٠ سطر بيعملوا اللي الكيت بيعمله. واتشال منه كمان تلات أرقام خام
/// (`64.w` · `32.h` · `28` والهامش `3.w`).
///
/// **والأهم إنه كان صعب يتقري**: خلفية خضرا مصمتة بحرف أبيض عليها كانت
/// أعلى صوت في شاشة التسجيل كلها — أعلى من زرار «سجّل». الـsegmented
/// لوح غاطس هادي، والمختار هو اللي بيرتفع.
///
/// **بيبان في التسجيل بس** — الحساب فيه صف «اللغة» بورقة اختيار.
class ChangeLanguageIconWidget extends StatelessWidget {
  const ChangeLanguageIconWidget({super.key});

  static const Locale _ar = Locale('ar', 'EG');
  static const Locale _en = Locale('en', 'US');

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';

    // الـsegmented تباعه `Expanded`، فمحتاج عرض محدود — من غير كده بياخد
    // الصف كله والوجو بيتزنق.
    return SizedBox(
      width: 104.w,
      child: AppSegmentedWidget<Locale>(
        value: isEnglish ? _en : _ar,
        segments: const [
          AppSegment(value: _ar, label: 'ع'),
          AppSegment(value: _en, label: 'EN'),
        ],
        onChanged: context.setLocale,
      ),
    );
  }
}
