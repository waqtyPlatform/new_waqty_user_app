import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_row_widget.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_booking_row_widget.dart';

/// التحميل بشكل [MyBookingRowWidget] بالظبط.
///
/// بيستخدم [AppRowWidget] نفسه بدل ما يقلّد حشوته — نفس سبب
/// `ProviderRowSkeletonWidget`: التقليد بيتكسر أول ما الحشوة تتغيّر أو
/// الصف يبقى كارت، والـ skeleton بيفضل على شكله القديم في صمت.
class MyBookingRowSkeletonWidget extends StatelessWidget {
  final bool showHairline;

  const MyBookingRowSkeletonWidget({super.key, this.showHairline = true});

  @override
  Widget build(BuildContext context) {
    return SkeletonGroupWidget(
      child: AppRowWidget(
        height: MyBookingRowWidget.heightOf(context),
        showHairline: showHairline,
        child: Column(
          // المستطيلات ارتفاعها ثابت والنص الحقيقي بيكبر مع المقياس،
          // فالفرق بيتوزّع فوق وتحت بالتساوي بدل ما يتجمّع تحت.
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBoxWidget(width: 132, height: 14, animate: false),
                const Spacer(),
                // بشكل الشارة — `pill` وعرض كلمتين. مستطيل مربّع هنا كان
                // بيخلي التحميل يقرا جدول مش صف فيه حالة.
                const SkeletonBoxWidget(
                  width: 56,
                  height: 18,
                  radius: AppRadius.pill,
                  animate: false,
                ),
              ],
            ),
            verticalSpace(AppSpacing.s8),
            const SkeletonBoxWidget(width: 168, height: 10, animate: false),
            verticalSpace(AppSpacing.s8),
            Row(
              children: [
                const SkeletonBoxWidget(width: 120, height: 10, animate: false),
                const Spacer(),
                const SkeletonBoxWidget(width: 44, height: 12, animate: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
