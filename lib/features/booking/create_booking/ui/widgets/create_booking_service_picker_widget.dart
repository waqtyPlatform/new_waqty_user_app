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
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
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
        // **مفيش عنوان هنا.** الرأس بتاع الـ sheet بيقول «اختار الخدمات»
        // خلاص — والعنوان التاني كان بيكرره حرفيًا تحته بـ٤٠ بكسل فرق.
        // السطر ده بيشرح **القاعدة** (متعدد) مش بيسمّي الخطوة تاني.
        Text(
          'تقدر تختار أكتر من خدمة في نفس الحجز',
          style: AppTextStyles.caption,
        ),
        verticalSpace(AppSpacing.headerToContent),

        // **قايمة بخط شعري، مش كروت طايرة.**
        //
        // أربع أسطح مرفوعة ورا بعض = أربع ظلال وأربع حدود، وكل واحد
        // بيقول «أنا جسم منفصل» — ولما الكل بيقولها محدش بيقولها. نفس
        // السبب اللي شال الكارت من قايمة الأماكن ومن صفوف الحجوزات.
        // والمكسب مش شكلي بس: أربع خدمات بقت تدخل في نص المساحة.
        AppSurfaceWidget(
          radius: AppRadius.m,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < bookable.length; i++)
                _ServiceRow(
                  service: bookable[i],
                  isSelected: isSelected(bookable[i].uuid),
                  showHairline: i != bookable.length - 1,
                  onTap: () => onToggle(bookable[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// صف خدمة واحدة.
///
/// ## السعر على سطر الاسم — مش في الناحية التانية من الشاشة
///
/// كان الاسم على اليمين والسعر على الشمال، والنص اللي بينهم فاضي. على
/// ٣٧٥ بكسل ده بيتقرا **جدول مكسور**، والعين بتلف مرتين لكل صف.
///
/// السعر جزء من قرار الاختيار، فمكانه جنب الحاجة اللي بيسعّرها: الاسم
/// والسعر على نفس السطر (نمط قايمة الأسعار المعروف)، والمدة تحت. حركة
/// عين واحدة بدل اتنين.
class _ServiceRow extends StatelessWidget {
  final ServiceUiModel service;
  final bool isSelected;
  final bool showHairline;
  final VoidCallback onTap;

  const _ServiceRow({
    required this.service,
    required this.isSelected,
    required this.showHairline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.standard,
        // الصف المختار بيتلوّن — **من غير حد**. الحد كان بيضيف تالت
        // إشارة (مربع + لون + حد) لحالة واحدة، والتلاتة مع بعض بيبقوا
        // ضوضاء مش تأكيد.
        color: isSelected
            ? AppSemanticColors.accentSoft
            : Colors.transparent,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.s12.w,
          vertical: AppSpacing.s12.h,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Checkbox(isSelected: isSelected),
                horizontalSpace(AppSpacing.s12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        // خط القاعدة مشترك — الاسم والسعر بيقعدوا على نفس
                        // السطر فعلاً، مش متوسطين كل واحد في صندوقه.
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMdStrong,
                            ),
                          ),
                          horizontalSpace(AppSpacing.s8),
                          Text(
                            AppFormat.money(service.price),
                            style: AppTextStyles.bodyMdStrong,
                          ),
                        ],
                      ),
                      verticalSpace(AppSpacing.titleToSubtitle),
                      Text(
                        AppFormat.duration(service.durationMinutes),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showHairline) ...[
              verticalSpace(AppSpacing.s12),
              // الخط بيبدأ بعد المربع — بيربط الصفوف من غير ما يقطع
              // عمود الاختيار.
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: (22 + AppSpacing.s12).w,
                ),
                child: const AppHairlineWidget(),
              ),
            ],
          ],
        ),
      ),
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
