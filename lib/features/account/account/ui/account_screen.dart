import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/account/data/models/account_menu_item_model.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/account/account/logic/account_state.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_header_card.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_menu_card.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_section_title.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountLogoutSuccessState) {
          context.pushNamedAndRemoveUntil(
            Routes.loginScreen,
            predicate: (_) => false,
          );
        }
      },
      builder: (context, state) {
        final cubit = AccountCubit.get(context);
        final isGuest = state is AccountLoadedState
            ? state.isGuest
            : cubit.isGuest;
        final isArabic = context.locale.languageCode.toLowerCase().startsWith(
          'ar',
        );

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 118.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AccountTopBar(isArabic: isArabic),
                AccountHeaderCard(isGuest: isGuest),
                if (isGuest)
                  ..._guestContent(context)
                else
                  ..._userContent(context),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _guestContent(BuildContext context) {
    return [
      AccountSectionTitle(title: context.tr('account.guestSectionTitle')),
      AccountMenuCard(
        items: [
          AccountMenuItemModel(
            title: context.tr('account.cityRegionTitle'),
            subtitle: context.tr('account.cityRegionSubtitle'),
            icon: Icons.location_on_outlined,
          ),
          AccountMenuItemModel(
            title: context.tr('account.languageTitle'),
            subtitle: context.tr('account.languageSubtitleGuest'),
            icon: Icons.map_outlined,
            onTap: () => context.pushNamed(Routes.languageScreen),
          ),
          AccountMenuItemModel(
            title: context.tr('account.supportTitleGuest'),
            subtitle: context.tr('account.supportSubtitleGuest'),
            icon: Icons.info_outline_rounded,
          ),
          AccountMenuItemModel(
            title: context.tr('account.termsPrivacyTitle'),
            icon: Icons.description_outlined,
          ),
        ],
      ),
    ];
  }

  List<Widget> _userContent(BuildContext context) {
    return [
      AccountSectionTitle(title: context.tr('account.accountSectionTitle')),
      AccountMenuCard(
        items: [
          AccountMenuItemModel(
            title: context.tr('account.profileTitle'),
            subtitle: context.tr('account.profileSubtitle'),
            icon: Icons.person_outline_rounded,
          ),
          AccountMenuItemModel(
            title: context.tr('account.phoneTitle'),
            subtitle: context.tr('account.phoneSubtitle'),
            icon: Icons.phone_outlined,
            trailing: const AccountVerifiedPill(),
          ),
          AccountMenuItemModel(
            title: context.tr('account.packagesTitle'),
            subtitle: context.tr('account.packagesSubtitle'),
            icon: Icons.local_offer_outlined,
          ),
          AccountMenuItemModel(
            title: context.tr('account.walletTitle'),
            subtitle: context.tr('account.walletSubtitle'),
            icon: Icons.account_balance_wallet_outlined,
          ),
          AccountMenuItemModel(
            title: context.tr('account.couponsTitle'),
            subtitle: context.tr('account.couponsSubtitle'),
            icon: Icons.receipt_long_outlined,
            trailing: AccountBadgePill(
              text: context.tr('account.couponsMetricValue'),
            ),
          ),
          AccountMenuItemModel(
            title: context.tr('account.paymentMethodsTitle'),
            subtitle: context.tr('account.paymentMethodsSubtitle'),
            icon: Icons.credit_card_outlined,
          ),
          AccountMenuItemModel(
            title: context.tr('account.paymentsTitle'),
            subtitle: context.tr('account.paymentsSubtitle'),
            icon: Icons.article_outlined,
          ),
          AccountMenuItemModel(
            title: context.tr('account.reviewsTitle'),
            subtitle: context.tr('account.reviewsSubtitle'),
            icon: Icons.star_border_rounded,
          ),
        ],
      ),
      AccountSectionTitle(title: context.tr('account.settingsSectionTitle')),
      AccountMenuCard(
        items: [
          AccountMenuItemModel(
            title: context.tr('account.languageTitle'),
            subtitle: context.tr('account.languageSubtitleUser'),
            icon: Icons.language_rounded,
            onTap: () => context.pushNamed(Routes.languageScreen),
          ),
          AccountMenuItemModel(
            title: context.tr('account.notificationsTitle'),
            subtitle: context.tr('account.notificationsSubtitle'),
            icon: Icons.notifications_none_rounded,
          ),
          AccountMenuItemModel(
            title: context.tr('account.helpTitle'),
            subtitle: context.tr('account.helpSubtitle'),
            icon: Icons.help_outline_rounded,
          ),
          AccountMenuItemModel(
            title: context.tr('account.inviteFriendsTitle'),
            subtitle: context.tr('account.inviteFriendsSubtitle'),
            icon: Icons.person_add_alt_1_outlined,
          ),
          AccountMenuItemModel(
            title: context.tr('account.termsPrivacyTitle'),
            icon: Icons.info_outline_rounded,
          ),
        ],
      ),
      SizedBox(height: 16.h),
      _LogoutButton(),
      SizedBox(height: 8.h),
      Text(
        context.tr('account.deleteAccount'),
        textAlign: TextAlign.center,
        style: TextStyles.font12greyColor500W600.copyWith(
          color: AppColors.errorColor200,
        ),
      ),
    ];
  }
}

class _AccountTopBar extends StatelessWidget {
  final bool isArabic;

  const _AccountTopBar({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final title = Expanded(
      child: Text(
        context.tr('account.title'),
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.font24greyColor900Weight600.copyWith(height: 1.3),
      ),
    );
    final notesButton = Container(
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.18),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: -8.r,
          ),
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
            blurRadius: 1.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Icon(
        Icons.receipt_long_outlined,
        color: AppColors.greyColor900,
        size: 18.sp,
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 8.h),
      child: Row(
        textDirection: TextDirection.ltr,
        children: isArabic
            ? [notesButton, SizedBox(width: 12.w), title]
            : [title, SizedBox(width: 12.w), notesButton],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode.toLowerCase().startsWith('ar');
    final logoutText = Text(
      context.tr('account.logoutButton'),
      style: TextStyles.font16greyColor900Weight600,
    );
    final logoutIcon = Icon(
      Icons.logout_rounded,
      color: AppColors.greyColor900,
      size: 18.sp,
    );

    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final isLoading = state is AccountLogoutLoadingState;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isLoading ? null : () => AccountCubit.get(context).logout(),
            child: Container(
              height: 46.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffF1F0EB),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.greyColor900,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: isArabic
                          ? [logoutIcon, SizedBox(width: 8.w), logoutText]
                          : [logoutText, SizedBox(width: 8.w), logoutIcon],
                    ),
            ),
          ),
        );
      },
    );
  }
}
