import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';

/// مؤشر الخطوات — تحت مقبض الـ sheet، **مش app bar فوق**.
///
/// الـ app bar بيدّي إحساس إن العميل خرج من صفحة المحل وراح مكان تاني.
/// إحنا عايزينه يحس إنه لسه واقف في المحل وبيختار.
class CreateBookingStepperWidget extends StatelessWidget {
  final BookingStep currentStep;

  const CreateBookingStepperWidget({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final index = BookingStep.values.indexOf(currentStep);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(BookingStep.values.length, (i) {
        final isActive = i <= index;
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 3.w),
          child: AnimatedContainer(
            duration: AppMotion.base,
            // **كان ناقصه `curve`** — من غيرها الحركة خطية، والخطي بيحس
            // ميكانيكي مهما كانت المدة مظبوطة.
            curve: AppMotion.standard,
            height: 6.h,
            width: i == index ? 22.w : 6.w,
            decoration: BoxDecoration(
              color: isActive
                  ? AppSemanticColors.accent
                  : AppSemanticColors.borderStrong,
              borderRadius: BorderRadius.circular(AppRadius.pill.r),
            ),
          ),
        );
      }),
    );
  }
}

/// مقبض السحب فوق الـ sheet.
class CreateBookingGrabberWidget extends StatelessWidget {
  const CreateBookingGrabberWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        verticalSpace(AppSpacing.s8),
        Container(
          height: 4.h,
          width: 40.w,
          decoration: BoxDecoration(
            color: AppSemanticColors.borderStrong,
            borderRadius: BorderRadius.circular(AppRadius.pill.r),
          ),
        ),
        verticalSpace(AppSpacing.headerToContent),
      ],
    );
  }
}
