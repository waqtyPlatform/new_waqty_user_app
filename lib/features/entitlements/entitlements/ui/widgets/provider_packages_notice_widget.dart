import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **«باقاتك هنا»** — باقات العميلة عند المزوّد اللي هي واقفة عليه.
///
/// ## اللي اتغيّر مع BE-A1
///
/// أول نسخة من الـwidget ده كانت **تذكرة مش قسم**: «عندك باقتين شغّالين ·
/// لو واحدة منها من الفرع ده، كلّم الفرع». الصياغة الشرطية دي مكانتش
/// تواضع — كانت الحقيقة الوحيدة اللي نقدر نقولها، لأن الرد مكانش فيه
/// `provider` والمطابقة بالخدمة مش صالحة (`Service` عنده `providers()`
/// belongsToMany، فـ«قص شعر» صف مشترك بين صالونات).
///
/// دلوقتي كل صف بيقول مزوّده، فالفلترة حقيقية والزرار بيحجز فعلاً.
///
/// ⚠ **الفلترة مسؤولية اللي بينده** — الـwidget ده بيرسم اللي يتبعتله.
/// حطّ الفلترة هنا كان هيخلّي كل مستهلك يفتكر يبعت المزوّد الصح.
class ProviderPackagesNoticeWidget extends StatelessWidget {
  const ProviderPackagesNoticeWidget({
    required this.packages,
    this.onOpen,
    this.onBook,
    super.key,
  });

  /// باقات المزوّد ده **الشغّالة بس**. قسم بيقول «عندك باقة» وهي منتهية
  /// وعد كاذب.
  final List<PackageEntitlementUiModel> packages;

  /// فتح «باقاتي».
  final VoidCallback? onOpen;

  /// حجز جلسة من باقة بعينها.
  final void Function(PackageEntitlementUiModel package)? onBook;

  @override
  Widget build(BuildContext context) {
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
                Icons.card_giftcard_rounded,
                size: 20.r,
                color: AppSemanticColors.accentText,
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Text(
                  'باقاتك هنا',
                  style: AppTextStyles.bodyMdStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onOpen != null)
                AppButtonWidget(
                  label: 'الكل',
                  variant: AppButtonVariant.ghost,
                  expand: false,
                  onPressed: onOpen,
                ),
            ],
          ),

          for (final package in packages) ...<Widget>[
            SizedBox(height: AppSpacing.s12.h),
            _Row(package: package, onBook: onBook),
          ],
        ],
      ),
    );
  }
}

/// صف باقة واحدة — الاسم والمتبقّي وزرار الحجز.
///
/// ⚠ **مش `const`** — بيرسم لون.
class _Row extends StatelessWidget {
  const _Row({required this.package, this.onBook});

  final PackageEntitlementUiModel package;
  final void Function(PackageEntitlementUiModel package)? onBook;

  /// المتبقّي بكلمات النوع بتاعه — الجلسات مش وحدات والعكس.
  String get _remaining => switch (package) {
    SessionPackageEntitlement(:final availableSessions, :final isSingleVisit) =>
      isSingleVisit
          ? 'زيارة واحدة'
          : 'فاضل ${AppFormat.digits(availableSessions)} جلسات',
    UsagePackageEntitlement(:final availableUnits, :final unitName) =>
      'فاضل ${AppFormat.digits(availableUnits)} $unitName',
  };

  @override
  Widget build(BuildContext context) {
    final bookable = package.isBookableFromApp && onBook != null;

    return Row(
      children: <Widget>[
        // النص هو اللي بيتنازل والزرار لأ — `Expanded` مش `Spacer`، عشان
        // الصف مايفيضش عند مقياس خط ١٫٣.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                package.packageName,
                style: AppTextStyles.bodyMd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _remaining,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.s8.w),
        if (bookable)
          AppButtonWidget(
            label: 'احجز',
            variant: AppButtonVariant.secondary,
            expand: false,
            onPressed: () => onBook!(package),
          ),
      ],
    );
  }
}
