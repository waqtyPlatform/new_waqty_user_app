import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';

/// مقبض السحب فوق الـ sheet.
///
/// **بقى علامة شكلية بس.** السحب لتحت اتقفل (`enableDrag: false`) لأنه
/// كان بيرمي السلة في صمت. المقبض بيفضل موجود لأنه بيقول «ده لوح فوق
/// الصفحة» — وشيله كان هيخلي الـ sheet يبان زي شاشة كاملة اتفتحت غلط.
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
        verticalSpace(AppSpacing.s8),
      ],
    );
  }
}

/// رأس الـ sheet — **رجوع · تقدّم**، في سطر واحد.
///
/// ## اللي اتشال: التلات نقط
///
/// كان فيه `CreateBookingStepperWidget` — تلات نقط من غير أي نص. تلات
/// نقط بتدّعي تلات وحدات شغل متساوية، والحقيقة إن حجز بتلات خدمات
/// **١٢ قرار** حداشر منهم جوه النقطة التانية. مؤشر بيقرا أقل من الحقيقة
/// أوحش من إنه مايبقاش موجود: العميل بيرتاح في اللحظة الغلط وبعدين
/// يحس إنه اتصاد.
///
/// وكمان كانت بتبان تلات نقط والأولى مليانة حتى لما العميل يدخل من صف
/// خدمة (الـ cubit بينطّ لخطوة المواعيد على طول) — يعني عدد النقط عمره
/// ما عبّر عن الخطوات اللي هيعدّي عليها فعلاً.
///
/// ## ليه سطر واحد
///
/// التلات معلومات دول بيجاوبوا تلات أسئلة العميل بيسألهم في نفس اللحظة:
/// «أقدر أرجع؟» و«فاضل قد إيه؟» و«أنا بحجز فين؟». لو اتفرقوا على تلات
/// سطور، الـ sheet بياكل ٧٢ بكسل من فوق قبل أي محتوى.
class CreateBookingHeaderWidget extends StatelessWidget {
  final BookingStep currentStep;

  /// كام خدمة اتحدد لها ميعاد، من كام. بيتعرض في خطوة المواعيد بس.
  final int scheduledCount;
  final int totalCount;

  /// `null` = مفيش رجوع من الخطوة دي (أول خطوة).
  final VoidCallback? onBack;

  const CreateBookingHeaderWidget({
    super.key,
    required this.currentStep,
    required this.scheduledCount,
    required this.totalCount,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // **[AppScreenHeaderWidget] — نفس الشكل بالظبط.**
    //
    // كان `Row` فيه دايرة رجوع + لابل في النص + `SizedBox(40.w)` بيوازن
    // الناحية التانية عشان اللابل يقع في النص فعلاً. ده تعريف هيدر
    // الكيت بالحرف، ومعاه: الارتفاع بيكبر مع مقياس الخط (`heightOf`)،
    // ومقاس الأيقونة الخام (`24.r`) والمساحة الخام (`40.w`) اتشالوا.
    //
    // **زرار الرجوع كان مفيش خالص** قبل كده. `previousStep()` كانت
    // مكتوبة في الـ cubit من الأول و**صفر callers** — wizard بتلات
    // خطوات من غير رجوع بيخلي العميل يخرج من الـ sheet كله عشان يعدّل
    // حاجة، وخروجه بيرمي السلة.
    //
    // ⚠ **مفيش `AppStepperWidget`.** الكيت شايل واحد، والويزارد ده كان
    // فيه `CreateBookingStepperWidget` بتلات نقط **واتشال بقرار**: تلات
    // نقط بتدّعي تلات وحدات شغل متساوية، وحجز بتلات خدمات **١٢ قرار**
    // حداشر منهم جوه النقطة التانية. مؤشر بيقرا أقل من الحقيقة أوحش من
    // إنه مايبقاش موجود. اللابل النصي تحت بيعدّ **الشغل** مش المراحل.
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.pageGutter.w,
      ),
      child: AppScreenHeaderWidget(title: _progressLabel, onBack: onBack),
    );
  }

  /// **بيعدّ الشغل مش المراحل.**
  ///
  /// التلات نقط القديمة كانت بتدّعي تلات وحدات شغل. حجز بتلات خدمات
  /// **١٢ قرار**، حداشر منهم جوه النقطة التانية — فالمؤشر كان بيقرا
  /// أقل من الحقيقة، والعميل بيرتاح في اللحظة الغلط وبعدين يتفاجئ.
  ///
  /// في خطوة المواعيد بنعد الخدمات لأن دي الوحدة اللي العميل شايلها
  /// فعلاً. في الخطوتين التانيتين بنقول اسم الخطوة وخلاص.
  String get _progressLabel => switch (currentStep) {
    BookingStep.service => 'اختار الخدمات',
    BookingStep.dateTime =>
      totalCount <= 1
          ? 'اختار الميعاد'
          : 'خدمة ${AppFormat.digits(_currentItem)} من ${AppFormat.digits(totalCount)}',
    BookingStep.confirm => 'مراجعة الحجز',
  };

  /// العنصر اللي العميل واقف عليه — أول واحد لسه من غير ميعاد.
  int get _currentItem {
    final next = scheduledCount + 1;
    return next > totalCount ? totalCount : next;
  }
}

/// شيب الفرع — سطر تحت الرأس.
///
/// ## ليه شيب مش خطوة
///
/// «أنهي فرع» هو **أول** قرار ذهني عند العميل، والفلو مكانش بيسأله خالص
/// — وكل اللي بعده (الأخصائيين، المواعيد، الأسعار، التوقيت) متعلّق
/// بالفرع. السكوت عليه بيخلي كل اختيار بعده مؤقت من غير ما حد يقول.
///
/// وخطوة كاملة كانت هتبقى احتكاك من غير مقابل للمحلات اللي ليها فرع
/// واحد — وهي الغالبية. الشيب بيقول الحقيقة وبيسمح بالتغيير، وبيختفي
/// لما مفيش اختيار أصلاً.
class CreateBookingBranchChipWidget extends StatelessWidget {
  final BranchUiModel? branch;
  final VoidCallback? onChangeBranch;

  const CreateBookingBranchChipWidget({
    super.key,
    required this.branch,
    this.onChangeBranch,
  });

  @override
  Widget build(BuildContext context) {
    final current = branch;
    if (current == null) return const SizedBox.shrink();

    final radius = BorderRadius.circular(AppRadius.pill.r);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.pageGutter.w,
        end: AppSpacing.pageGutter.w,
        top: AppSpacing.s8.h,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Material(
          color: AppSemanticColors.surfaceSunken,
          borderRadius: radius,
          child: InkWell(
            onTap: onChangeBranch,
            borderRadius: radius,
            // **الحشوة والحجم اتكبروا — ده كنترول مش شارة.**
            //
            // كان `overline` (١١) وهو **أصغر حجم في الأبلكيشن**، مخصص
            // للشارات اللي بتتقرا وخلاص («مؤكد» · «آخر موعد»). لكن ده
            // بيتداس، وبيغيّر **سياق الحجز كله**: الأخصائيين والمواعيد
            // والأسعار كلهم بيتبعوا الفرع.
            //
            // بقى `captionInk` (١٢ حبر غامق) لاسم الفرع و`label` (١٤
            // أخضر) لـ«تغيير» — نفس الستايل بتاع كل الروابط في الأبلكيشن.
            // والحشوة الرأسية بقت ٨ بدل ٤ عشان هدف اللمس يبقى معقول.
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.s12.w,
                vertical: AppSpacing.s8.h,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 16.r,
                    color: AppSemanticColors.textSecondary,
                  ),
                  horizontalSpace(AppSpacing.s4),
                  Flexible(
                    child: Text(
                      current.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.captionInk,
                    ),
                  ),
                  // مفيش «تغيير» لما مفيش فرع تاني — الكلمة بتوعد
                  // باختيار مش موجود.
                  if (onChangeBranch != null) ...[
                    horizontalSpace(AppSpacing.s8),
                    Text('تغيير', style: AppTextStyles.label),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
