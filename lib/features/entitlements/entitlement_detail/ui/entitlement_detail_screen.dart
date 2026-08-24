import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_detail/ui/widgets/entitlement_allowed_services_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_detail/ui/widgets/entitlement_detail_header_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_detail/ui/widgets/entitlement_purchases_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_detail/ui/widgets/entitlement_usage_ledger_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/logic/entitlement_booking_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/ui/entitlement_booking_sheet.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_progress_widget.dart';

/// تفاصيل استحقاق واحد — باقة أو متابعة.
///
/// ## ليه شاشة واحدة للنوعين
///
/// لأن السؤال واحد: **«إيه اللي عندي بالظبط، وإيه اللي أقدر أعمله بيه؟»**
/// الأجزاء اللي بتترسم بتختلف (دفتر الوحدات للبركة · الشراءات للمتجمّع ·
/// قاعدة الأخصائي للمتابعة)، بس الهيكل والسؤال واحد — وشاشتين كانوا
/// هيكرّروا الهيدر والحالة وسطر الصلاحية.
class EntitlementDetailScreen extends StatelessWidget {
  const EntitlementDetailScreen({this.package, this.followUp, super.key})
    : assert(
        package != null || followUp != null,
        'لازم استحقاق واحد على الأقل',
      );

  final PackageEntitlementUiModel? package;
  final FollowUpEntitlementUiModel? followUp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSemanticColors.page,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.pageGutter.w,
            end: AppSpacing.pageGutter.w,
            bottom: AppSpacing.screenBottom.h,
          ),
          children: <Widget>[
            AppScreenHeaderWidget(
              title: 'تفاصيل',
              onBack: () => Navigator.of(context).pop(),
            ),
            verticalSpace(AppSpacing.s16),

            if (package != null) ..._packageBody(context, package!),
            if (followUp != null) ..._followUpBody(context, followUp!),
          ],
        ),
      ),
    );
  }

  /// بيحجز جلسة من باقة، وبعد التأكيد بيقفل التفاصيل — الاستحقاق اتغيّر
  /// فإبقاء الشاشة على أرقامه القديمة بيخلّي العميلة تبص على «متاح» لحاجة
  /// حجزتها توّها.
  Future<void> _bookPackage(
    BuildContext context,
    PackageEntitlementUiModel entitlement,
  ) async {
    final booked = await EntitlementBookingSheet.showForPackage(
      context,
      cubit: EntitlementsCubit.get(context),
      package: entitlement,
    );

    if (!context.mounted || booked == null) return;
    await EntitlementBookingSheet.showConfirmation(
      context,
      booking: booked,
      kind: EntitlementBookingKind.package,
    );

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  List<Widget> _packageBody(
    BuildContext context,
    PackageEntitlementUiModel entitlement,
  ) {
    return <Widget>[
      EntitlementDetailHeaderWidget(
        title: entitlement.packageName,
        subtitle: switch (entitlement) {
          SessionPackageEntitlement(:final serviceName) => serviceName,
          UsagePackageEntitlement(:final unitName) => 'رصيد بالـ$unitName',
        },
        owner: entitlement.owner,
        status: entitlement.status,
        purchasedAt: entitlement.purchasedAt,
        expiresAt: entitlement.expiresAt,
      ),
      verticalSpace(AppSpacing.s24),

      switch (entitlement) {
        SessionPackageEntitlement(
          :final completedSessions,
          :final reservedSessions,
          :final availableSessions,
        ) =>
          EntitlementProgressWidget(
            used: completedSessions,
            reserved: reservedSessions,
            available: availableSessions,
          ),
        UsagePackageEntitlement(
          :final totalUnitsConsumed,
          :final availableUnits,
        ) =>
          EntitlementProgressWidget(
            used: totalUnitsConsumed,
            reserved: 0,
            available: availableUnits,
            usedLabel: 'اتصرف',
          ),
      },

      if (entitlement case UsagePackageEntitlement(
        :final allowedServices,
        :final purchases,
        :final usageHistory,
        :final purchaseCount,
      )) ...<Widget>[
        if (allowedServices.isNotEmpty) ...<Widget>[
          verticalSpace(AppSpacing.s24),
          EntitlementAllowedServicesWidget(services: allowedServices),
        ],
        if (purchaseCount > 1) ...<Widget>[
          verticalSpace(AppSpacing.s24),
          EntitlementPurchasesWidget(purchases: purchases),
        ],
        if (usageHistory.isNotEmpty) ...<Widget>[
          verticalSpace(AppSpacing.s24),
          EntitlementUsageLedgerWidget(transactions: usageHistory),
        ],
      ],

      verticalSpace(AppSpacing.s24),
      if (entitlement.isBookableFromApp)
        AppButtonWidget(
          label: 'احجز جلسة',
          onPressed: () => _bookPackage(context, entitlement),
        )
      else if (entitlement.blockedReason != null)
        AppBannerWidget(
          message: entitlement.blockedReason!,
          icon: Icons.info_outline_rounded,
        ),
    ];
  }

  /// بيحجز، وبعد التأكيد **بيقفل شاشة التفاصيل**.
  ///
  /// الاستحقاق اتغيّر (جلسة اتحجزت)، فإبقاء الشاشة مفتوحة على بياناته
  /// القديمة بيخلّي العميلة تبص على «متاحة» لحاجة هي حجزتها توّها.
  Future<void> _book(
    BuildContext context,
    FollowUpEntitlementUiModel entitlement,
  ) async {
    final booked = await EntitlementBookingSheet.showForFollowUp(
      context,
      cubit: EntitlementsCubit.get(context),
      followUp: entitlement,
    );

    if (!context.mounted || booked == null) return;
    await EntitlementBookingSheet.showConfirmation(context, booking: booked);

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  List<Widget> _followUpBody(
    BuildContext context,
    FollowUpEntitlementUiModel entitlement,
  ) {
    return <Widget>[
      EntitlementDetailHeaderWidget(
        title: 'متابعة ${entitlement.serviceName}',
        subtitle: entitlement.isFree
            ? 'المتابعة دي مجانية'
            : AppFormat.money(entitlement.effectivePrice),
        owner: entitlement.owner,
        status: entitlement.status,
        expiresAt: entitlement.validUntil,
      ),
      verticalSpace(AppSpacing.s24),

      // ⚠ **السطرين مربوطين بوجود الأخصائي، مش بالقاعدة لوحدها.**
      //
      // لما الأخصائي يمشي بيرجع `null` والقاعدة بتفضل `sameRequired` — يعني
      // الشاشة كانت بتقول «المتابعة مع نفس الأخصائي» (من غير اسم) وتحتها
      // على طول بانر بيقول إنه مابقاش متاح. جملتين بيناقضوا بعض في نفس
      // الشاشة، وبينهم فراغ صف الاسم اللي اتشال.
      if (entitlement.employee != null) ...<Widget>[
        AppDetailRowWidget(
          label: 'الأخصائي',
          value: entitlement.employee!.name,
        ),
        if (entitlement.employeeRule == FollowUpEmployeeRule.sameRequired)
          Padding(
            padding: EdgeInsetsDirectional.only(top: AppSpacing.s8.h),
            child: Text(
              'المتابعة مع نفس الأخصائي',
              style: AppTextStyles.caption,
            ),
          ),
        verticalSpace(AppSpacing.s24),
      ],

      if (entitlement.isBookableFromApp)
        AppButtonWidget(
          label: 'احجز المتابعة',
          onPressed: () => _book(context, entitlement),
        )
      else if (entitlement.blockedReason != null)
        AppBannerWidget(
          message: entitlement.blockedReason!,
          tone: AppPillTone.warning,
          icon: Icons.info_outline_rounded,
        ),
    ];
  }
}
