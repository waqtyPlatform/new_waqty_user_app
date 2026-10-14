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
          _MoneyRow(
            label: context.tr('providerBooking.servicesTotal'),
            amount: cart.servicesTotal > 0 ? cart.servicesTotal : cart.subtotal,
            currencyCode: cart.currencyCode,
          ),
          if (cart.hasServiceFee) ...[
            const SizedBox(height: 5),
            _MoneyRow(
              label: context.tr('providerBooking.serviceFee'),
              amount: cart.serviceFee,
              currencyCode: cart.currencyCode,
            ),
          ],
          if (cart.hasTax) ...[
            const SizedBox(height: 5),
            _MoneyRow(
              label: context.tr('providerBooking.tax'),
              amount: cart.tax,
              currencyCode: cart.currencyCode,
            ),
          ],
          if (cart.hasDiscount) ...[
            const SizedBox(height: 5),
            _MoneyRow(
              label: context.tr('providerBooking.discount'),
              amount: -cart.discount,
              currencyCode: cart.currencyCode,
            ),
          ],
          const Divider(height: 18),
          _MoneyRow(
            label: context.tr('providerBooking.estimatedTotal'),
            amount: cart.estimatedTotal > 0
                ? cart.estimatedTotal
                : cart.subtotal,
            currencyCode: cart.currencyCode,
            emphasized: true,
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

class _MoneyRow extends StatelessWidget {
  final String label, currencyCode;
  final double amount;
  final bool emphasized;

  const _MoneyRow({
    required this.label,
    required this.amount,
    required this.currencyCode,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final amountText =
        '${NumberFormat.decimalPattern(locale).format(amount.abs())} $currencyCode';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: emphasized
              ? TextStyles.font14greyColor900Weight600
              : TextStyles.font12greyColor500W400,
        ),
        Text(
          amount < 0 ? '-$amountText' : amountText,
          style: emphasized
              ? TextStyles.font16greyColor900Weight600
              : TextStyles.font12greyColor500W400,
        ),
      ],
    );
  }
}
