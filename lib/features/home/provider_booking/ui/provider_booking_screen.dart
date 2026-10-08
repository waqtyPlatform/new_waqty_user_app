import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';

class ProviderBookingScreen extends StatelessWidget {
  final String providerUuid;
  final String branchUuid;
  final String providerName;

  const ProviderBookingScreen({
    super.key,
    required this.providerUuid,
    required this.branchUuid,
    required this.providerName,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.pageColor,
    appBar: AppBar(
      backgroundColor: AppColors.pageColor,
      title: Text(context.tr('providerBooking.title')),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: Text(
            context.tr('providerBooking.addItems'),
            style: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    ),
  );
}
