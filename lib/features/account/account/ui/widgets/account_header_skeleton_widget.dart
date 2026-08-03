import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_header_widget.dart';

/// التحميل بارتفاع [AccountHeaderWidget] بالظبط.
///
/// كان مستطيل ٦٤ باستدارة ٣٢ — يعني كان بيوعد بدايرة، والدايرة اتشالت.
/// دلوقتي بياخد ارتفاعه من `AccountHeaderWidget.heightOf` نفسها، فلو حد
/// غيّر مقاس الاسم بكرة الـ skeleton بيتغيّر معاه من غير ما حد يفتكره.
///
/// العرضين (١٧٦ و١١٢) تقريب لاسم من كلمتين ورقم موبايل — مش مقاسات ثابتة
/// من سلّم، دي **أشكال نص** الغرض منها إن الشاشة الفاضية تقرا زي الشاشة
/// المليانة.
class AccountHeaderSkeletonWidget extends StatelessWidget {
  const AccountHeaderSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonGroupWidget(
      child: SizedBox(
        height: AccountHeaderWidget.heightOf(context).h,
        // المستطيلات دي **حبر النص مش صندوق السطر** — عشان كده أقصر من
        // ٣٦٫٨ و١٦٫٨. اللي لازم يطابق هو الإجمالي بره، وده مضمون من
        // الـ SizedBox؛ والتوسيط بيحط الحبر في نص السطر زي الخط الحقيقي.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBoxWidget(width: 176, height: 24, animate: false),
            verticalSpace(AppSpacing.titleToSubtitle),
            SkeletonBoxWidget(width: 112, height: 10, animate: false),
          ],
        ),
      ),
    );
  }
}
