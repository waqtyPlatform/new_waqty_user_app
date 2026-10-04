import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/account/account/data/models/account_menu_item_model.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_menu_card.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_section_title.dart';

class GuestAccountContent extends StatelessWidget {
  const GuestAccountContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
      ],
    );
  }
}
