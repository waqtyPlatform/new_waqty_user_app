import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

import '../../logic/booking_cart_cubit.dart';
import '../../logic/booking_cart_state.dart';
import '../../logic/booking_cart_timer_cubit.dart';
import 'booking_cart_checkout_bar.dart';
import 'booking_cart_hold_countdown.dart';
import 'booking_cart_item.dart';

class BookingCartBody extends StatelessWidget {
  final BookingCartState state;
  const BookingCartBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cart = state.cart;
    if (cart == null || cart.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: context.read<BookingCartCubit>().load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * .24),
            const Icon(
              Icons.shopping_bag_outlined,
              size: 54,
              color: AppColors.greyColor300,
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('providerBooking.cartEmpty'),
              textAlign: TextAlign.center,
              style: TextStyles.font16greyColor900Weight600,
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('providerBooking.cartEmptyHint'),
              textAlign: TextAlign.center,
              style: TextStyles.font12greyColor500W400,
            ),
          ],
        ),
      );
    }
    return BlocProvider(
      key: ValueKey(cart.expiresAt),
      create: (_) => BookingCartTimerCubit(
        remainingSeconds: cart.expiresInSeconds,
        expiresAt: cart.expiresAt,
        serverTime: cart.serverTime,
      )..start(),
      child: BlocListener<BookingCartTimerCubit, int>(
        listenWhen: (previous, current) => previous > 0 && current == 0,
        listener: (context, _) =>
            context.read<BookingCartCubit>().load(silent: true),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: context.read<BookingCartCubit>().load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    BookingCartHoldCountdown(
                      expirationHours:
                          cart.expiresInHours ??
                          (cart.expiresInSeconds == null
                              ? null
                              : cart.expiresInSeconds! / 3600),
                    ),
                    const SizedBox(height: 16),
                    for (final item in cart.items) ...[
                      BookingCartItem(item: item, disabled: state.mutating),
                      const SizedBox(height: 12),
                    ],
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 4),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OutlinedButton.icon(
                          onPressed: state.mutating
                              ? null
                              : context.read<BookingCartCubit>().clear,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                          ),
                          label: Text(context.tr('providerBooking.clearCart')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorColor200,
                            backgroundColor: AppColors.errorColor0,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            side: const BorderSide(
                              color: AppColors.errorColor50,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyles.font12greyColor500W400
                                .copyWith(
                                  color: AppColors.errorColor200,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BookingCartCheckoutBar(cart: cart, loading: state.mutating),
          ],
        ),
      ),
    );
  }
}
