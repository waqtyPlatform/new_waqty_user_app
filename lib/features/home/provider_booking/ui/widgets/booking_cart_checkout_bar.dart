import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

import '../../data/models/booking_cart_model.dart';
import '../../logic/booking_cart_cubit.dart';
import '../../logic/booking_cart_timer_cubit.dart';

class BookingCartCheckoutBar extends StatelessWidget {
  final BookingCartModel cart;
  final bool loading;

  const BookingCartCheckoutBar({
    super.key,
    required this.cart,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(top: BorderSide(color: AppColors.greyColor100)),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: .06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('providerBooking.subtotal'),
                style: TextStyles.font14greyColor500W400,
              ),
              Text(
                '${NumberFormat.decimalPattern(locale).format(cart.subtotal)} ${cart.currencyCode}',
                style: TextStyles.font16greyColor900Weight600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<BookingCartTimerCubit, int>(
            builder: (context, remaining) => SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: loading || remaining <= 0
                    ? null
                    : context.read<BookingCartCubit>().checkout,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.greyColor900,
                  disabledBackgroundColor: AppColors.greyColor200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  context.tr(
                    loading
                        ? 'providerBooking.checkingOut'
                        : 'providerBooking.checkout',
                  ),
                  style: TextStyles.font14whiteColorWeight500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
