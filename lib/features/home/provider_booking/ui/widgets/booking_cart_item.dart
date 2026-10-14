import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

import '../../data/models/booking_cart_model.dart';
import '../../logic/booking_cart_cubit.dart';

class BookingCartItem extends StatelessWidget {
  final BookingCartItemModel item;
  final bool disabled;

  const BookingCartItem({
    super.key,
    required this.item,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final startsAt = item.startsAt?.toLocal();
    final appointment = startsAt == null
        ? ''
        : DateFormat('EEE d MMM - h:mm a', locale).format(startsAt);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyColor1001),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: .025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.greenColor505,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: AppColors.greenColor500,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font14greyColor900Weight600.copyWith(
                    height: 1.3,
                  ),
                ),
                if (appointment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(appointment, style: TextStyles.font12greyColor500W400),
                ],
                if (item.employee != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    context.tr(
                      'providerBooking.withEmployee',
                      args: [item.employee!.name],
                    ),
                    style: TextStyles.font12greyColor500W400,
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  '${NumberFormat.decimalPattern(locale).format(item.price)} ${item.currencyCode}',
                  style: TextStyles.font12greenColor500W600,
                ),
                if (item.remainingHours != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    context.tr(
                      'providerBooking.cartReleaseMessage',
                      args: [_hoursText(item.remainingHours!)],
                    ),
                    style: TextStyles.font12greyColor500W400,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
            padding: EdgeInsets.zero,
            onPressed: disabled
                ? null
                : () => context.read<BookingCartCubit>().deleteItem(item.uuid),
            tooltip: context.tr('providerBooking.removeItem'),
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.errorColor100,
          ),
        ],
      ),
    );
  }
}

String _hoursText(double hours) => hours == hours.roundToDouble()
    ? hours.toInt().toString()
    : hours.toStringAsFixed(1);
