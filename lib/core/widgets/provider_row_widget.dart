import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// المكان **كصف في قايمة**.
///
/// ## اللوح كبر و«أقرب موعد» بقى شارة
///
/// اللوح كان ٥٦ والسطر الرابع («أقرب موعد») نص أخضر مدفون تحت البيانات.
/// حاجتين اتغيّروا:
///
/// **اللوح ٦٤.** الأبلكيشن مالوش صور، والحرف ده الهوية البصرية الوحيدة لكل
/// محل. عند ٥٦ بيقرا أيقونة؛ عند ٦٤ بيقرا **صورة المحل** — وده اللي بيخلي
/// القايمة تتقرا كفاترينة مش كجدول.
///
/// **«أقرب موعد» بقى شارة.** ده أبلكيشن حجز، والمعلومة دي هي اللي بتفرّق
/// محل عن محل. كنص أخضر بين تلات سطور نص، بتضيع. كشارة، ليها حدود وخلفية
/// فبتقرا كحالة مش كجملة.
class ProviderRowWidget extends StatelessWidget {
  /// مقاس لوح الحرف. **٦٤ مش ٥٦.**
  static const double avatarSize = 64;

  /// إزاحة الفاصل: هامش الصفحة + اللوح + المسافة.
  ///
  /// مصدّرة عشان أي حاجة تانية في نفس اللستة تمشي على نفس الإزاحة بدل ما
  /// تعيد حساب الرقم بإيدها.
  static const double hairlineIndent =
      AppSpacing.pageGutter + avatarSize + AppSpacing.listRowGap;

  /// ١٢ حشوة فوق + ١٢ تحت (من [AppRowWidget]) = ٢٤، زائد المسافات جوه عمود
  /// النص: ٤ + ٤ + ٤ = ١٢، زائد حشوة الشارة الرأسية (٤ فوق + ٤ تحت) = ٨.
  /// **المجموع ٤٤.**
  ///
  /// ⚠ **مشتق من التوكنز مش رقم مكتوب.** كان ٥٢ مكتوب بالإيد لما
  /// `cardPadding` كانت ١٦؛ الكيت نزّلها ١٢ والرقم فضل مكانه، يعني ٨
  /// بكسل هوا ميت في كل صف مقدّم خدمة وفي الـ skeleton بتاعه. الاختبار
  /// ماكانش هيمسكها: [AppRowWidget] بيطرح حشوته من الارتفاع قبل الصندوق
  /// الداخلي، فالمرسوم بيساوي المحسوب مهما كانت الحشوة.
  ///
  /// المسافة بين المنطقة وسطر البيانات نزلت من ٨ لـ ٤: التلات سطور دول
  /// **بيانات المحل نفسه** ومش محتاجين فصل بينهم — الفصل الحقيقي بين
  /// الاسم وبينهم، وده لسه ٤ لأن الوزن هو اللي بيفصل مش المسافة.
  static const double _fixedPart =
      (AppSpacing.cardPadding * 2) + (AppSpacing.s4 * 3) + AppSpacing.s8;

  /// عند مقياس ١٫٠: `cardTitle` ٢٢٫٤ + `caption` ١٦٫٨ + `captionInk` ١٦٫٨
  /// + نص الشارة (`captionStrong` ١٢×١٫٤٠ = ١٦٫٨). المجموع الحسابي **٧٢٫٨**،
  /// والرقم هنا ٧٥ لأن فلاتر بيقرّب ارتفاع السطر لأعلى وقت التشكيل.
  ///
  /// كان ٧٢ لما الشارة كانت `overline` (١١sp). شارة الكيت `captionStrong`،
  /// يعني سطرها زاد ٢٫٥ مش نقص — عكس اللي التقليم الأول افترضه.
  static const double _textPart = 75;

  /// المصدر الوحيد للارتفاع — **و`ProviderRowSkeletonWidget` بيقراه من هنا**.
  ///
  /// مساحة الشارة محجوزة حتى لو المحل مالوش موعد قريب. لو الارتفاع اتحسب
  /// على اللي ظاهر، اللستة كانت هترقص بين صف وصف.
  static double heightOf(BuildContext context) =>
      AppSpacing.scaledHeight(context, fixed: _fixedPart, text: _textPart);

  final ProviderUiModel provider;
  final VoidCallback onTap;

  /// آخر صف في القايمة بياخد `false` — مافيش مسافة تحته.
  final bool showHairline;

  const ProviderRowWidget({
    super.key,
    required this.provider,
    required this.onTap,
    this.showHairline = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasSlot = provider.nextAvailableLabel.isNotEmpty;

    return AppRowWidget(
      onTap: onTap,
      height: heightOf(context).h,
      showHairline: showHairline,
      // **`entity` مش `person`** — ده محل مش أخصائي. المربّع المستدير بيقرا
      // «مكان» والدايرة بتقرا «حد».
      leading: EntityAvatarWidget(
        name: provider.name,
        size: avatarSize,
        shape: AvatarShape.entity,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle,
          ),
          verticalSpace(AppSpacing.titleToSubtitle),
          Text(
            '${provider.categoryName} · ${provider.areaName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
          verticalSpace(AppSpacing.s4),
          Text(
            _metrics,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionInk,
          ),
          verticalSpace(AppSpacing.s4),
          // **الشارة موجودة في الحالتين.**
          //
          // كانت بتتحوّل لـ `SizedBox` فاضي لما المحل مالوش موعد قريب —
          // الارتفاع كان بيفضل ثابت (فالقايمة مابترقصش) بس المساحة كانت
          // **فراغ ميت** في صف من كل تلاتة.
          //
          // «مفيش مواعيد قريبة» معلومة حقيقية في أبلكيشن حجز: بتخلي العميل
          // يعدّي بدل ما يدخل ويكتشف بنفسه. ورماديها بيقول إنها مش فرصة.
          if (hasSlot)
            AppPillWidget(
              label: 'أقرب موعد ${provider.nextAvailableLabel}',
              icon: Icons.schedule_rounded,
              tone: AppPillTone.accent,
            )
          else
            const AppPillWidget(
              label: 'مفيش مواعيد قريبة',
              icon: Icons.event_busy_rounded,
            ),
        ],
      ),
    );
  }

  String get _metrics => <String>[
    AppFormat.distance(provider.distanceKm),
    'من ${AppFormat.money(provider.priceFrom)}',
    '${AppFormat.digits(provider.servicesCount)} خدمة',
  ].join(' · ');
}
