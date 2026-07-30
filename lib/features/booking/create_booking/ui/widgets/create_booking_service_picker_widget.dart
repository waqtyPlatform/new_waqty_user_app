import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_motion.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// اختيار الخدمات — **متعدد**.
///
/// كان اختيار واحد بشكل راديو. السيرفر بيقبل لحد ٥٠ خدمة في الحجز
/// الواحد من زمان، والعميل اللي جاي يقص ويحلق كان بيضطر يعمل حجزين
/// ويتمنى إنهم يطلعوا ورا بعض.
///
/// ## ليه مربع اختيار مش مجرد لون
///
/// الاختيار المتعدد لازم يبان إنه متعدد **قبل** ما العميل يختار حاجة.
/// اللون لوحده بيتقرا كـ «ده اللي مختار دلوقتي» — يعني راديو. المربع
/// الفاضي جنب كل صف بيقول «تقدر تاخد أكتر من واحدة» من أول نظرة.
class CreateBookingServicePickerWidget extends StatelessWidget {
  final List<ServiceUiModel> services;

  /// بترجع `true` لو الخدمة دي في السلة.
  final bool Function(String serviceUuid) isSelected;
  final ValueChanged<ServiceUiModel> onToggle;

  const CreateBookingServicePickerWidget({
    super.key,
    required this.services,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bookable = services.where((s) => !s.isCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اختر الخدمات', style: AppTextStyles.sectionHeader),
        verticalSpace(AppSpacing.s4),
        Text(
          'تقدر تختار أكتر من خدمة في نفس الحجز',
          style: AppTextStyles.caption,
        ),
        verticalSpace(AppSpacing.headerToContent),
        ...bookable.map((service) {
          final selected = isSelected(service.uuid);

          return Padding(
            padding: EdgeInsetsDirectional.only(bottom: AppSpacing.chipGap.h),
            child: AppSurfaceWidget(
              onTap: () => onToggle(service),
              radius: AppRadius.m,
              height: 64.h,
              color: selected ? AppSemanticColors.accentSoft : null,
              // **الحالة المختارة هي واحدة من تلات حالات بس بتاخد حد.**
              // الحد هنا معناه دلالي («ده اختيارك») مش فصل بصري.
              border: selected
                  ? Border.all(color: AppSemanticColors.accent, width: 1.5)
                  : null,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
              child: Row(
                children: [
                  _Checkbox(isSelected: selected),
                  horizontalSpace(AppSpacing.s12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMdStrong,
                        ),
                        verticalSpace(AppSpacing.titleToSubtitle),
                        Text(
                          AppFormat.duration(service.durationMinutes),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  horizontalSpace(AppSpacing.s8),
                  Text(
                    AppFormat.money(service.price),
                    style: AppTextStyles.bodyMdStrong,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// مربع الاختيار — بيتملي بحركة بدل ما يتبدّل فجأة.
class _Checkbox extends StatelessWidget {
  final bool isSelected;

  const _Checkbox({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.base,
      curve: AppMotion.standard,
      height: 22.r,
      width: 22.r,
      decoration: BoxDecoration(
        color: isSelected ? AppSemanticColors.accent : Colors.transparent,
        // **`xs` مش `s`.** الاستدارة `s` تساوي ١٢ على مربع ٢٢ — ونص الـ
        // ٢٢ هو ١١، يعني أي قيمة فوقها بتطلع **دايرة كاملة**. والدايرة
        // بتتقري radio: «اختار واحدة بس» — عكس رسالة الشاشة دي بالظبط.
        borderRadius: BorderRadius.circular(AppRadius.xs.r),
        border: Border.all(
          color: isSelected
              ? AppSemanticColors.accent
              : AppSemanticColors.borderStrong,
          width: 1.5,
        ),
      ),
      child: AnimatedScale(
        scale: isSelected ? 1 : 0,
        duration: AppMotion.fast,
        curve: AppMotion.emphasis,
        child: Icon(
          Icons.check_rounded,
          size: 16.r,
          color: AppSemanticColors.textOnAccent,
        ),
      ),
    );
  }
}
