import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class BookingCartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BookingCartAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 68,
    backgroundColor: AppColors.pageColor,
    surfaceTintColor: Colors.transparent,
    automaticallyImplyLeading: false,
    centerTitle: true,
    title: Text(
      context.tr('providerBooking.cartTitle'),
      style: TextStyles.font16greyColor900Weight400,
    ),
    leadingWidth: 64,
    leading: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: .10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.greyColor900,
            ),
          ),
        ),
      ),
    ),
  );
}
