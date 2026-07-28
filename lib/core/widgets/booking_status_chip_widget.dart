import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// شارة حالة الحجز.
///
/// اللفظ جاي من `BookingStatus.label` — الأسماء الداخلية زي `no_show`
/// مصطلحات تقنية ومتتعرضش زي ما هي للعميل.
///
/// اتنقلت هنا من جوه `my_booking_card_widget.dart` عشان صفحة التفاصيل كانت
/// بتستوردها من ملف كارت اللستة — **وكانت بترسمها بحشوة تانية** (١٢/٤ بدل
/// ١٠/٣)، فنفس الحالة كانت شكلها مختلف في الشاشتين.
class BookingStatusChipWidget extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusChipWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill.r),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.overline.copyWith(color: foreground),
      ),
    );
  }

  (Color, Color) get _colors => switch (status) {
    BookingStatus.pending => (
      AppSemanticColors.warningSoft,
      AppSemanticColors.warning,
    ),
    BookingStatus.confirmed => (
      AppSemanticColors.accentSoft,
      AppSemanticColors.accent,
    ),
    BookingStatus.inProgress => (
      AppSemanticColors.infoSoft,
      AppSemanticColors.info,
    ),
    BookingStatus.completed => (
      AppSemanticColors.positiveSoft,
      AppSemanticColors.positive,
    ),
    BookingStatus.noShow => (
      AppSemanticColors.dangerSoft,
      AppSemanticColors.danger,
    ),
    // الإلغاء بأنواعه التلاتة — رمادي مش أحمر. الأحمر بيقرا «فيه مشكلة»
    // والإلغاء غالبًا العميل هو اللي عمله.
    _ => (
      AppSemanticColors.surfaceSunken,
      AppSemanticColors.textSecondary,
    ),
  };
}
