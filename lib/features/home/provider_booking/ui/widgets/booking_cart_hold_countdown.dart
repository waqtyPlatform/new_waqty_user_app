import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

import '../../logic/booking_cart_timer_cubit.dart';

class BookingCartHoldCountdown extends StatelessWidget {
  final String? expirationMessage;

  const BookingCartHoldCountdown({super.key, this.expirationMessage});

  @override
  Widget build(BuildContext context) => BlocBuilder<BookingCartTimerCubit, int>(
    builder: (context, remaining) {
      final hours = (remaining ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((remaining % 3600) ~/ 60).toString().padLeft(2, '0');
      final seconds = (remaining % 60).toString().padLeft(2, '0');
      return Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.warningColor0,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.warningColor25),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.warningColor50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_outlined,
                size: 18,
                color: AppColors.warningColor200,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                expirationMessage ??
                    context.tr('providerBooking.cartExpiresIn'),
                style: TextStyles.font12greyColor900Weight400,
              ),
            ),
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text(
                '$hours:$minutes:$seconds',
                style: TextStyles.font14greyColor900Weight600.copyWith(
                  letterSpacing: .3,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
