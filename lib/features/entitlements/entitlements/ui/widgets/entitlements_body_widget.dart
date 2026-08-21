import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/phone_claim_result_ui_model.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
// `show` مش استيراد كامل: `account_state` و`my_bookings_state` الاتنين
// فيهم `InitialState`، والتصادم بيوقف الترجمة.
import 'package:waqty_user_application/features/account/account/logic/account_state.dart'
    show AccountState;
import 'package:waqty_user_application/features/account/phone_verification/ui/widgets/phone_claim_result_sheet.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/ui/entitlement_booking_sheet.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_detail/ui/entitlement_detail_screen.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_state.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_card_skeleton_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlement_empty_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/follow_up_card_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/package_session_card_widget.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/package_usage_card_widget.dart';

/// **جسم «باقاتي ومتابعاتي»** — المقسّم والقايمة والحالات.
///
/// ## ليه widget مشترك مش شاشة
///
/// نفس المحتوى بيتعرض في مكانين: **تبويب تالت جوه «حجوزاتي»** (المدخل
/// الأساسي — العميلة بتفتح التبويب ده وهي بتفكّر في مواعيدها)، و**شاشة
/// كاملة** من صف «حسابي» (البيت الدايم).
///
/// لو الاتنين اتكتبوا لوحدهم، أول تغيير في حالة فاضية أو ترتيب كارت هيمشي
/// في واحد ويسيب التاني — والعميلة هتشوف شكلين لنفس الحاجة حسب الطريق
/// اللي جت منه.
class EntitlementsBodyWidget extends StatelessWidget {
  const EntitlementsBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntitlementsCubit, EntitlementsState>(
      builder: (context, state) {
        final cubit = EntitlementsCubit.get(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
              ),
              child: AppSegmentedWidget<EntitlementTab>(
                value: cubit.tab,
                onChanged: cubit.selectTab,
                segments: <AppSegment<EntitlementTab>>[
                  for (final tab in EntitlementTab.values)
                    AppSegment<EntitlementTab>(value: tab, label: tab.label),
                ],
              ),
            ),
            verticalSpace(AppSpacing.s16),
            Expanded(child: _list(context, cubit, state)),
          ],
        );
      },
    );
  }

  Widget _list(
    BuildContext context,
    EntitlementsCubit cubit,
    EntitlementsState state,
  ) {
    if (state is EntitlementsError) {
      return Padding(
        padding: AppSpacing.page,
        child: AppErrorStateWidget(message: state.message, onRetry: cubit.load),
      );
    }

    if (state is EntitlementsInitial || state is EntitlementsLoading) {
      return ListView(
        padding: _padding,
        children: const <Widget>[
          EntitlementCardSkeletonWidget(),
          EntitlementCardSkeletonWidget(),
          EntitlementCardSkeletonWidget(),
        ],
      );
    }

    if (cubit.isCurrentTabEmpty) {
      return RefreshIndicator(
        onRefresh: cubit.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: _padding,
          children: <Widget>[
              // ⚠ **`BlocBuilder` على `AccountCubit` مش قراية مباشرة.**
              //
              // النص هنا بيتفرّع على `phone_verified_at`، والحساب
              // والاستحقاقات بيتحمّلوا **متوازيين**. لو الحساب خلص بعد
              // الاستحقاقات، القراية المباشرة كانت بتشوف `null` وترسم
              // «لسه مافيش باقات» — و**مافيش حاجة بترجع تبنيها تاني**،
              // فالعميلة اللي رقمها مش مأكّد كانت بتقعد على النص الغلط.
              BlocBuilder<AccountCubit, AccountState>(
                builder: (context, _) {
                  final account = AccountCubit.get(context).account;
                  return EntitlementEmptyWidget(
                    tab: cubit.tab,
                    // `null` = الحساب لسه بيتحمّل. مابنفترضش حاجة — النص
                    // المحايد لحد ما نعرف، عشان مانوجّهش عميلة رقمها
                    // مأكّد لتأكيد تاني.
                    needsVerification:
                        account != null && !account.isPhoneVerified,
                    onVerify: () => _verifyPhone(context, cubit),
                  );
                },
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: _padding,
        children: switch (cubit.tab) {
          EntitlementTab.packages => <Widget>[
            for (final package in cubit.packages)
              _packageCard(context, package),
          ],
          EntitlementTab.followUps => <Widget>[
            for (final followUp in cubit.followUps)
              FollowUpCardWidget(
                followUp: followUp,
                onBook: followUp.isBookableFromApp
                    ? () => _book(context, cubit, followUp)
                    : null,
                onTap: () => _openDetail(context, followUp: followUp),
              ),
          ],
        },
      ),
    );
  }

  /// **الفرز بالنوع — ودي الحتة اللي بتمنع «كارت وحدات بيقول جلسات».**
  ///
  /// `switch` على `sealed` بيخلّي المترجم يرفض لو نوع تالت اتضاف
  /// ومااتعالجش، بدل ما يقع على كارت افتراضي غلط.
  Widget _packageCard(BuildContext context, PackageEntitlementUiModel package) {
    return switch (package) {
      SessionPackageEntitlement() => PackageSessionCardWidget(
        package: package,
        onTap: () => _openDetail(context, package: package),
      ),
      UsagePackageEntitlement() => PackageUsageCardWidget(
        package: package,
        onTap: () => _openDetail(context, package: package),
      ),
    };
  }

  void _openDetail(
    BuildContext context, {
    PackageEntitlementUiModel? package,
    FollowUpEntitlementUiModel? followUp,
  }) {
    final cubit = EntitlementsCubit.get(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<EntitlementsCubit>.value(
          value: cubit,
          child: EntitlementDetailScreen(package: package, followUp: followUp),
        ),
      ),
    );
  }

  /// بيفتح شيت الحجز، وبعد النجاح **بيقول اللي حصل**.
  ///
  /// من غير التأكيد ده الشيت بيقفل في صمت والعميلة مش متأكدة إن الحجز
  /// اتسجّل — وهي مش هتلاقي رقم حجز تراجعه لأن السيرفر بيرجّع موديل خام
  /// (BE-A2). فالسكوت هنا أوحش من أي مكان تاني.
  Future<void> _book(
    BuildContext context,
    EntitlementsCubit cubit,
    FollowUpEntitlementUiModel followUp,
  ) async {
    final booked = await EntitlementBookingSheet.show(
      context,
      cubit: cubit,
      followUp: followUp,
    );

    if (!context.mounted || !booked) return;
    await EntitlementBookingSheet.showConfirmation(context);
  }

  /// نفس مسار F2 — وبعد النجاح **بنعيد تحميل الاستحقاقات**، لأن ده كل
  /// الغرض من تأكيد الرقم أصلاً.
  Future<void> _verifyPhone(
    BuildContext context,
    EntitlementsCubit cubit,
  ) async {
    final accountCubit = AccountCubit.get(context);
    final result = await Navigator.of(
      context,
    ).pushNamed(Routes.phoneVerificationScreen);

    if (!context.mounted) return;
    if (result is! PhoneClaimResultUiModel) return;

    await accountCubit.getProfile();
    if (!context.mounted) return;
    await cubit.load();

    if (!context.mounted) return;
    await PhoneClaimResultSheet.show(
      context,
      result: result,
      packagesFound: cubit.packages.length,
    );
  }

  EdgeInsetsGeometry get _padding => EdgeInsetsDirectional.only(
    start: AppSpacing.pageGutter.w,
    end: AppSpacing.pageGutter.w,
    bottom: AppSpacing.screenBottom.h,
  );
}
