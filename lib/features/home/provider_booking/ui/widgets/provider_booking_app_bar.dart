import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/provider_booking/logic/booking_cart_cubit.dart';
import 'package:waqty_user_application/features/home/provider_booking/logic/booking_cart_state.dart';

import '../booking_cart_screen.dart';

class ProviderBookingAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ProviderBookingAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: AppColors.pageColor,
    surfaceTintColor: Colors.transparent,
    automaticallyImplyLeading: false,
    centerTitle: true,
    title: Text(
      context.tr('providerBooking.title'),
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
    actions: [
      BlocBuilder<BookingCartCubit, BookingCartState>(
        buildWhen: (previous, current) =>
            previous.cart?.itemsCount != current.cart?.itemsCount,
        builder: (context, state) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  final cartCubit = context.read<BookingCartCubit>()..load();
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cartCubit,
                        child: const BookingCartScreen(),
                      ),
                    ),
                  );
                },
                tooltip: context.tr('providerBooking.cartTitle'),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.whiteColor,
                  foregroundColor: AppColors.greyColor900,
                ),
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              if ((state.cart?.itemsCount ?? 0) > 0)
                PositionedDirectional(
                  end: -2,
                  top: -2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.greenColor500,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${state.cart!.itemsCount}',
                      style: TextStyles.font12whiteColorWeight600.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
