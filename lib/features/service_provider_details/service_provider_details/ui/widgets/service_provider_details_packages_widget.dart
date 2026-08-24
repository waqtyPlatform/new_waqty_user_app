import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_offer_ui_model.dart';
import 'package:waqty_user_application/core/widgets/discount_price_widget.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **«باقات المكان»** — اللي الفرع ده بيبيعه.
///
/// ## مش «باقاتك هنا»
///
/// القسم اللي فوقه بيقول اللي العميلة **شارياه**؛ ده بيقول اللي **معروض
/// للبيع**. القسمين متجاورين بالقصد وبنفس الترتيب دايمًا: اللي دفعتِ فيه
/// الأول، اللي ممكن تدفعي فيه بعده. العكس بيبان كإعلان فوق حاجة مدفوعة.
///
/// ⚠ **الفلترة بالفرع مسؤولية الكيوبت.** الـwidget بيرسم اللي يتبعتله،
/// نفس قاعدة `ProviderPackagesNoticeWidget` — ولنفس السبب: لو فلتر من
/// عنده، كل مستهلك جديد لازم يفتكر يبعت الفرع الصح.
///
/// ⚠ **مافيش زرار شرا.** الشرا بيكتب فلوس — بيعمل `CustomerPackagePurchase`
/// وبياخد دفعة، والفرع هو اللي بياخدها النهاردة. مافيش endpoint للعميلة
/// ولا بوابة دفع، فالقسم بيقول السعر ويوجّه للفرع. زرار «اشتري» بيفتح
/// شاشة مش موجودة أسوأ من مفيش زرار.
class ServiceProviderDetailsPackagesWidget extends StatelessWidget {
  const ServiceProviderDetailsPackagesWidget({
    required this.packages,
    this.onOpen,
    super.key,
  });

  /// باقات **الفرع المختار**.
  final List<PackageOfferUiModel> packages;

  /// فتح تفاصيل باقة.
  final void Function(PackageOfferUiModel package)? onOpen;

  @override
  Widget build(BuildContext context) {
    // الفرع مش بايع باقات — القسم بيختفي بالكامل. قوقعة فاضية اسمها
    // «باقات المكان» بتخلّي الصفحة تبان ناقصة، وأغلب الفروع كده فعلاً.
    if (packages.isEmpty) return const SizedBox.shrink();

    return AppSurfaceWidget(
      level: AppElevation.raised,
      radius: AppRadius.m,
      padding: EdgeInsets.all(AppSpacing.cardPaddingLoose.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.inventory_2_outlined,
                size: 20.r,
                color: AppSemanticColors.accentText,
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Text(
                  'باقات المكان',
                  style: AppTextStyles.bodyMdStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s4.h),
          Text(
            'بتتشتري من الفرع، وبتوفّر لو بتيجي كتير',
            style: AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          for (final package in packages) ...<Widget>[
            SizedBox(height: AppSpacing.s12.h),
            _Row(package: package, onOpen: onOpen),
          ],
        ],
      ),
    );
  }
}

/// صف باقة معروضة.
///
/// ⚠ **مش `const`** — بيرسم لون.
class _Row extends StatelessWidget {
  const _Row({required this.package, this.onOpen});

  final PackageOfferUiModel package;
  final void Function(PackageOfferUiModel package)? onOpen;

  /// **إيه اللي بتاخده** — بكلمات شكلها.
  ///
  /// ⚠ البركة بتتكلم بالوحدة اللي السيرفر سمّاها، والزيارة الواحدة
  /// مابتقولش «1 جلسة».
  String get _content => switch (package.type) {
    PackageOfferType.multiSession =>
      '${AppFormat.digits(package.sessionsIncluded ?? 0)} جلسات',
    PackageOfferType.usageBased =>
      '${AppFormat.digits(package.initialUnits ?? 0)} ${package.unitName ?? 'وحدة'}',
    PackageOfferType.singleVisit => 'زيارة واحدة',
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen == null ? null : () => onOpen!(package),
      borderRadius: BorderRadius.circular(AppRadius.s.r),
      // ⚠ **٤٤ حد أدنى مش زخرفة.** الصف سطرين فبيعدّي الحد عادةً، بس عند
      // اسم قصير ومقياس خط صغير بينزل تحته — والقاعدة على الحاجة اللي
      // بتتداس مش على شكلها الغالب.
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: AppSpacing.touchTarget.r),
        child: Row(
          children: <Widget>[
            // النص هو اللي بيتنازل والسعر لأ — الرقم عمره ما يتقص.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    package.name,
                    style: AppTextStyles.bodyMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _content,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.s8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppFormat.money(package.effectivePrice),
                  style: AppTextStyles.bodyMdStrong,
                  maxLines: 1,
                ),
                // السعر القديم مشطوب — من غيره الرقم الأقل مالوش مرجع
                // والعميلة ماتعرفش إنها بتوفّر.
                if (package.hasOffer)
                  DiscountPriceWidget(amount: package.basePrice),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
