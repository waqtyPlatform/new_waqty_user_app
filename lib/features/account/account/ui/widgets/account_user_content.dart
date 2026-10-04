import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/account/data/models/account_menu_item_model.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_logout_button.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_menu_card.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_section_title.dart';

class AccountUserContent extends StatelessWidget {
  const AccountUserContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountSectionTitle(title: context.tr('account.accountSectionTitle')),
        AccountMenuCard(items: _accountItems(context)),
        AccountSectionTitle(title: context.tr('account.settingsSectionTitle')),
        AccountMenuCard(items: _settingsItems(context)),
        SizedBox(height: 16.h),
        const AccountLogoutButton(),
        SizedBox(height: 8.h),
        Text(
          context.tr('account.deleteAccount'),
          textAlign: TextAlign.center,
          style: TextStyles.font12greyColor500W600.copyWith(
            color: AppColors.errorColor200,
          ),
        ),
      ],
    );
  }

  List<AccountMenuItemModel> _accountItems(BuildContext context) {
    return [
      AccountMenuItemModel(
        title: context.tr('account.profileTitle'),
        subtitle: context.tr('account.profileSubtitle'),
        icon: Icons.person_outline_rounded,
        onTap: () => context.pushNamed(Routes.profileScreen),
      ),
      AccountMenuItemModel(
        title: context.tr('account.phoneTitle'),
        subtitle: context.tr('account.phoneSubtitle'),
        icon: Icons.phone_outlined,
        onTap: () => context.pushNamed(Routes.changePhoneScreen),
      ),
      AccountMenuItemModel(
        title: context.tr('account.packagesTitle'),
        subtitle: context.tr('account.packagesSubtitle'),
        icon: Icons.local_offer_outlined,
        onTap: () => context.pushNamed(Routes.packagesFollowingScreen),
      ),
      AccountMenuItemModel(
        title: context.tr('account.walletTitle'),
        subtitle: context.tr('account.walletSubtitle'),
        icon: Icons.account_balance_wallet_outlined,
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
    ];
  }

  List<AccountMenuItemModel> _settingsItems(BuildContext context) {
    return [
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
    ];
  }
}
