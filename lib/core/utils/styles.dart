import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors_white_theme.dart';
import 'app_text_styles.dart';

/// الستايلات القديمة.
///
/// **الجديد في `AppTextStyles`.** الملف ده باقي عشان شاشات الـ auth (~١٠٠
/// موضع) اللي متفق إننا مانلمسش تخطيطها — كل ستايل هنا بيتحوّل تدريجيًا
/// للتوكن المقابل له.
class TextStyles {
  // Welcome Text Styles

  static TextStyle font24greyColor900Weight600 = TextStyle(
    fontSize: 24.sp,
    height: 1.4,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );

  /// كان بيطلب `w700` **ومفيش ملف Bold في المشروع** — فالفلاتر كان بيولّد
  /// التخانة صناعيًا، وده بيلطّخ وصلات الحروف العربية ويملا العيون.
  /// نزل ٦٠٠ (أتقل وزن عندنا ملف حقيقي ليه).
  static TextStyle font14Weight700 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font14greyColor4002Weight400 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.greyColor4002,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font12greyColor4002Weight400 = TextStyle(
    fontSize: 12.sp,
    height: 1.6,
    color: AppColors.greyColor4002,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font12greenColor500W600 = TextStyle(
    fontSize: 12.sp,
    height: 1.6,
    color: AppColors.greenColor500,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font14greenColor500Weight400 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.greenColor500,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font14greyColor900Weight400 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );
  static TextStyle font14greyColor900Weight500 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w500,
    fontFamily: 'IBMPlexSansArabic',
  );
  static TextStyle font14greyColor900Weight600 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );
  static TextStyle font12greyColor900Weight400 = TextStyle(
    fontSize: 12.sp,
    height: 1.6,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font14whiteColorWeight500 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w500,
    fontFamily: 'IBMPlexSansArabic',
  );
  static TextStyle font12whiteColorWeight600 = TextStyle(
    fontSize: 12.sp,
    height: 1.6,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font20greyColor900W600 = TextStyle(
    fontSize: 20.sp,
    height: 1.4,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );
  static TextStyle font14greenColor500Weight600 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.greenColor500,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font14greyColor500W500 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.greyColor500,
    fontWeight: FontWeight.w500,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font14greyColor500W400 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.greyColor500,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font12greyColor500W400 = TextStyle(
    fontSize: 12.sp,
    height: 1.6,
    color: AppColors.greyColor500,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font14whiteColorWeight400 = TextStyle(
    fontSize: 14.sp,
    height: 1.6,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );

  /// ⚠ الاسم بيقول `Weight500` وهو بيحط `w400`. مانغيّرش الاسم في مكانه
  /// عشان الـ ١١ موضع اللي بيستخدموه كلهم في `features/auth` — بيتوجّه
  /// للتوكن المسمّى صح بدل ما نلمس ملفات مش من نطاقنا.
  static TextStyle font16greyColor4002Weight500 = AppTextStyles.bodyLgMuted;

  static TextStyle font16greyColor900Weight400 = TextStyle(
    fontSize: 16.sp,
    height: 1.6,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w400,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font18greyColor900Weight600 = TextStyle(
    fontSize: 18.sp,
    height: 1.4,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font16greyColor900Weight600 = TextStyle(
    fontSize: 16.sp,
    height: 1.6,
    color: AppColors.greyColor900,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );

  static TextStyle font16whiteColorWeight600 = TextStyle(
    fontSize: 16.sp,
    height: 1.6,
    color: AppColors.whiteColor,
    fontWeight: FontWeight.w600,
    fontFamily: 'IBMPlexSansArabic',
  );

  /// نص وhint كل حقول الإدخال في الأبلكيشن (٧ مواضع).
  ///
  /// كان بيطلب خط `DMSans` **وهو مش مسجّل في `pubspec.yaml`** — يعني كل
  /// الفورمات كانت بترسم بخط النظام الافتراضي بدل خط الأبلكيشن، والعربي
  /// فيها مكانش بيتوصّل صح.
  ///
  /// ارتفاع الحقول مش هيتغيّر — الحشوة مكتوبة صراحة في كل حقل — الشكل بس.
  static TextStyle font16BlackColorWeight400 = AppTextStyles.bodyLg;
}
