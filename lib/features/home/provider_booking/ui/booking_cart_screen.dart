import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';

import '../logic/booking_cart_cubit.dart';
import '../logic/booking_cart_state.dart';
import 'widgets/booking_cart_app_bar.dart';
import 'widgets/booking_cart_body.dart';
import 'widgets/booking_cart_shimmer.dart';

class BookingCartScreen extends StatelessWidget {
  const BookingCartScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<BookingCartCubit, BookingCartState>(
        listenWhen: (previous, current) =>
            previous.actionId != current.actionId,
        listener: (context, state) {
          if (state.action == BookingCartAction.checkedOut) {
            AppConstant.toast(
              context.tr('providerBooking.checkoutSuccess'),
              true,
              context,
            );
            Navigator.pop(context);
          } else if (state.action == BookingCartAction.itemDeleted) {
            AppConstant.toast(
              context.tr('providerBooking.itemRemoved'),
              true,
              context,
            );
          } else if (state.action == BookingCartAction.cartCleared) {
            AppConstant.toast(
              context.tr('providerBooking.cartCleared'),
              true,
              context,
            );
          } else if (state.action == BookingCartAction.failed) {
            AppConstant.toast(
              context.tr(bookingCartErrorKey(state.errorCode)),
              false,
              context,
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.pageColor,
          appBar: const BookingCartAppBar(),
          body: SafeArea(
            top: false,
            child: state.loading
                ? const BookingCartShimmer()
                : BookingCartBody(state: state),
          ),
        ),
      );
}

String bookingCartErrorKey(String? code) => switch (code) {
  'SLOT_UNAVAILABLE' => 'providerBooking.slotUnavailable',
  'CART_ITEM_EXPIRED' => 'providerBooking.cartItemExpired',
  'CART_CONTEXT_MISMATCH' => 'providerBooking.cartContextChanged',
  _ => 'providerBooking.cartError',
};
