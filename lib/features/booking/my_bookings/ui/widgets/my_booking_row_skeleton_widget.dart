import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_booking_row_widget.dart';

/// التحميل بشكل [MyBookingRowWidget] بالظبط — **بما فيه الخط الشعري**.
///
/// الارتفاع والحشوة بيتقروا من الصف نفسه، فعدم التطابق بقى مستحيل بنيويًا:
/// أي سطر يتزوّد في الصف بيكبّر الـ skeleton معاه من غير ما حد يفتكر.
///
/// قبل كده التحميل كان `SkeletonBoxWidget` بارتفاع الكارت وفاصل ١٢ بينه
/// وبين اللي بعده. دلوقتي الصف بيرسم خطه الشعري بنفسه، فلو الـ skeleton
/// فضل مستطيلات بفواصل، اللستة كانت هتزحلق بكسل لكل صف أول ما الداتا توصل.
///
/// موجة الـ shimmer واحدة للصف كله ([SkeletonGroupWidget] بره) — المستطيلات
/// جواها كلها `animate: false` عشان مايبقاش وميض عشوائي بدل موجة ماشية.
class MyBookingRowSkeletonWidget extends StatelessWidget {
  final bool showHairline;

  const MyBookingRowSkeletonWidget({super.key, this.showHairline = true});

  @override
  Widget build(BuildContext context) {
    return SkeletonGroupWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: MyBookingRowWidget.heightOf(context).h,
            child: Padding(
              // نفس حشوة [AppRowWidget] بالظبط.
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
                vertical: AppSpacing.cardPadding.h,
              ),
              child: Column(
                // المستطيلات ارتفاعها ثابت والنص الحقيقي بيكبر مع المقياس،
                // فالفرق بيتوزّع فوق وتحت بالتساوي بدل ما يتجمّع تحت.
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonBoxWidget(width: 132, height: 14, animate: false),
                      const Spacer(),
                      // بشكل الشارة — `pill` وعرض كلمتين. مستطيل مربّع هنا
                      // كان بيخلي التحميل يقرا جدول مش صف فيه حالة.
                      SkeletonBoxWidget(
                        width: 56,
                        height: 18,
                        radius: AppRadius.pill,
                        animate: false,
                      ),
                    ],
                  ),
                  verticalSpace(AppSpacing.s8),
                  SkeletonBoxWidget(width: 168, height: 10, animate: false),
                  verticalSpace(AppSpacing.s8),
                  Row(
                    children: [
                      SkeletonBoxWidget(width: 120, height: 10, animate: false),
                      const Spacer(),
                      SkeletonBoxWidget(width: 44, height: 12, animate: false),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // نفس إزاحة [AppRowWidget] لما `hairlineIndent` تبقى فاضية —
          // الافتراضي جوه [AppHairlineWidget] نفسه صفر، فلازم تتكتب هنا.
          if (showHairline)
            const AppHairlineWidget(indent: AppSpacing.pageGutter),
        ],
      ),
    );
  }
}
