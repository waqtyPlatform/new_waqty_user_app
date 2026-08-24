import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_icon_button_widget.dart';

/// هيدر الشاشة — **بيستبدل تسع نسخ**.
///
/// employee-app فيه **٩ implementations لنفس الهيدر** (٤٨ ارتفاع، دايرة
/// رجوع، عنوان في النص):
///
/// | | |
/// |---|---|
/// | `AccountSupportHeaderWidget(titleKey)` · `PayslipHeaderWidget(titleKey)` | بياخدوا **مفتاح ترجمة** وبينادوا `context.tr()` |
/// | `AppPinHeaderWidget(title, canPop)` | أحسن واحد فيهم — بياخد نص جاهز |
/// | `change_pin_header` · `working_hours_header` · `my_earning_header` · `earning_trend_header` · `daily_earning_details_header` · `booking_details_header` | **بصفر باراميتر** — كل واحد حاطط مفتاح عنوانه و`Navigator.pop` جوّه |
///
/// الكيت بياخد شكل `AppPinHeaderWidget`: **نص عادي مش مفتاح**، و`onBack`
/// كولباك.
///
/// ⚠ **ليه `onBack` كولباك مش `Navigator.maybePop`:** هيدر جوه bottom
/// sheet أو nested navigator بيقفل الحاجة الغلط. اللي بينده هو اللي
/// بيملك التنقّل، والكيت مايعرفش حاجة عن راوتات التطبيق.
class AppScreenHeaderWidget extends StatelessWidget {
  const AppScreenHeaderWidget({
    required this.title,
    this.onBack,
    this.trailing,
    this.subtitle,
    super.key,
  });

  /// **نص جاهز — مش مفتاح ترجمة.** الكيت مالوش لوكلة.
  final String title;

  /// `null` = مفيش زرار رجوع.
  final VoidCallback? onBack;

  final Widget? trailing;
  final Widget? subtitle;

  /// ارتفاع الهيدر من غير عنوان فرعي.
  static const double height = AppSpacing.headerHeight;

  static const double _fixedPart = 16;

  /// `sectionHeader` = 18 × 1.35 ≈ 24.3، **+1 هامش تقريب**: فلاتر بيقرّب
  /// ارتفاع السطر لأعلى وقت التشكيل، والحسبة الدقيقة بتسيب صفر فراغ.
  static const double _textPart = 25;

  /// **ارتفاع الهيدر كله.**
  ///
  /// عند مقياس ١٫٠ الدايرة (٤٨) هي اللي بتحكم؛ عند ١٫٣ النص بيعدّيها،
  /// فالـ `max` بيخلي الاتنين مضبوطين من غير ما الهيدر يقفز.
  static double heightOf(BuildContext context) => math.max(
    height,
    AppSpacing.scaledHeight(context, fixed: _fixedPart, text: _textPart),
  );

  @override
  Widget build(BuildContext context) {
    final back = onBack == null
        ? null
        : AppIconButtonWidget(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
            size: height,
          );

    // ⚠ `arrow_back_rounded` معرّفة بـ `matchTextDirection: true` — فلاتر
    // بيعكسها لوحده في الـ RTL. **ماتقلبهاش بإيدك**، بتتقلب مرتين وترجع
    // غلط.
    return SizedBox(
      height: subtitle == null ? heightOf(context).h : null,
      child: Row(
        children: [
          if (back != null) ...[back, SizedBox(width: AppSpacing.s8.w)],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.sectionHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.titleToSubtitle.h),
                  DefaultTextStyle(
                    style: AppTextStyles.caption,
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpacing.s8.w),
            trailing!,
          ] else if (back != null)
            // مساحة مطابقة للدايرة عشان العنوان يفضل في النص فعلاً
            // لما مافيش trailing.
            SizedBox(width: (height + AppSpacing.s8).w),
        ],
      ),
    );
  }
}

/// نسخة الـ skeleton — **بتقرا نفس الـ static**.
///
/// من غير كده، الهيدر بينطّ أول ما الداتا توصل.
class AppScreenHeaderSkeletonWidget extends StatelessWidget {
  const AppScreenHeaderSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppScreenHeaderWidget.heightOf(context).h,
      child: Row(
        children: [
          Container(
            width: AppScreenHeaderWidget.height.r,
            height: AppScreenHeaderWidget.height.r,
            decoration: BoxDecoration(
              color: AppSemanticColors.skeletonBase,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
          Expanded(
            child: Container(
              height: 16.h,
              decoration: BoxDecoration(
                color: AppSemanticColors.skeletonBase,
                borderRadius: AppRadius.rPill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
