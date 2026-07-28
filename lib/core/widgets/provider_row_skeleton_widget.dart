import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
import 'package:waqty_user_application/core/widgets/provider_row_widget.dart';
import 'package:waqty_user_application/core/widgets/skeleton_box_widget.dart';

/// التحميل بشكل [ProviderRowWidget] بالظبط — **بما فيه الخط الشعري**.
///
/// الارتفاع والحشوة والإزاحة كلهم بيتقروا من ثوابت الصف نفسه، فعدم
/// التطابق بقى مستحيل بنيويًا: لو حد زوّد سطر في الصف، الـ skeleton بيكبر
/// معاه من غير ما حد يفتكر يعدّله.
///
/// والخط الشعري لازم يبقى هنا كمان: من غيره اللستة بتزحلق بكسل لكل صف لما
/// الداتا توصل — وعشرين صف يبقى عشرين بكسل قفزة.
///
/// موجة الـ shimmer واحدة للصف كله ([SkeletonGroupWidget] بره) بدل موجة لكل
/// مستطيل — من غيرها بيبقى وميض عشوائي مش حركة ماشية.
class ProviderRowSkeletonWidget extends StatelessWidget {
  final bool showHairline;

  const ProviderRowSkeletonWidget({super.key, this.showHairline = true});

  @override
  Widget build(BuildContext context) {
    return SkeletonGroupWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: ProviderRowWidget.heightOf(context).h,
            child: Padding(
              // نفس حشوة [AppRowWidget] بالظبط.
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
                vertical: AppSpacing.cardPadding.h,
              ),
              child: Row(
                children: [
                  SkeletonBoxWidget(
                    width: ProviderRowWidget.avatarSize,
                    height: ProviderRowWidget.avatarSize,
                    radius: AppRadius.xs,
                    animate: false,
                  ),
                  horizontalSpace(AppSpacing.listRowGap),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الأعراض بتقلّ وبتزيد زي النص الحقيقي — الاسم أطول
                        // من التصنيف، والبيانات أطول من الاتنين. أربع
                        // مستطيلات متساوية بتقرا جدول مش نص.
                        SkeletonBoxWidget(width: 140, height: 14, animate: false),
                        verticalSpace(AppSpacing.s8),
                        SkeletonBoxWidget(width: 100, height: 10, animate: false),
                        verticalSpace(AppSpacing.s8),
                        SkeletonBoxWidget(width: 168, height: 10, animate: false),
                        verticalSpace(AppSpacing.s8),
                        SkeletonBoxWidget(width: 120, height: 10, animate: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showHairline)
            const AppHairlineWidget(indent: ProviderRowWidget.hairlineIndent),
        ],
      ),
    );
  }
}
