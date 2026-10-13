import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/features/home/provider_details/logic/provider_details_cubit.dart';
import 'package:waqty_user_application/features/home/provider_details/logic/provider_details_state.dart';
import 'package:waqty_user_application/features/home/provider_details/ui/widgets/provider_booking_flow_sheet.dart';

import '../data/models/provider_booking_items_model.dart';
import '../logic/provider_booking_items_cubit.dart';
import '../logic/provider_booking_items_state.dart';
import 'widgets/provider_booking_app_bar.dart';
import 'widgets/provider_booking_body.dart';

class ProviderBookingScreen extends StatelessWidget {
  final String providerUuid;
  final String branchUuid;
  final String providerName;
  final String? serviceUuid;
  final String? employeeUuid;

  const ProviderBookingScreen({
    super.key,
    required this.providerUuid,
    required this.branchUuid,
    required this.providerName,
    this.serviceUuid,
    this.employeeUuid,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.pageColor,
    appBar: const ProviderBookingAppBar(),
    body: BlocBuilder<ProviderBookingItemsCubit, ProviderBookingItemsState>(
      builder: (context, state) => ProviderBookingBody(
        providerName: providerName,
        state: state,
        onContinue: () => _continueBooking(context, state),
      ),
    ),
  );

  Future<void> _continueBooking(
    BuildContext context,
    ProviderBookingItemsState selection,
  ) async {
    final uuid = selection.selectedUuid;
    if (uuid == null) return;
    final itemsCubit = context.read<ProviderBookingItemsCubit>();
    final detailsCubit = context.read<ProviderDetailsCubit>();
    final item =
        selection.type == ProviderBookingItemType.ownedPackages ||
            selection.type == ProviderBookingItemType.followUps
        ? _selectedEntitlement(selection, uuid)
        : null;
    if ((selection.type == ProviderBookingItemType.ownedPackages &&
            item == null) ||
        (selection.type == ProviderBookingItemType.followUps &&
            item?.serviceUuid == null)) {
      AppConstant.toast(
        context.tr('providerBooking.loadError'),
        false,
        context,
      );
      return;
    }
    if (!itemsCubit.beginContinue()) return;
    try {
      unawaited(_prepareBooking(context, selection, uuid, item, detailsCubit));
      await showProviderBookingFlow(context);
    } finally {
      if (!itemsCubit.isClosed) itemsCubit.finishContinue();
    }
  }

  Future<void> _prepareBooking(
    BuildContext context,
    ProviderBookingItemsState selection,
    String uuid,
    ProviderBookingEntitlementModel? item,
    ProviderDetailsCubit detailsCubit,
  ) async {
    var detailsState = detailsCubit.state;
    if (detailsState is! ProviderDetailsLoaded) {
      detailsState = await detailsCubit.stream.firstWhere(
        (state) =>
            state is ProviderDetailsLoaded ||
            state is ProviderDetailsError ||
            state is ProviderDetailsNotFound,
      );
    }
    if (detailsState is! ProviderDetailsLoaded) {
      if (!context.mounted) return;
      AppConstant.toast(
        context.tr('providerBooking.loadError'),
        false,
        context,
      );
      Navigator.of(context).maybePop();
      return;
    }
    if (selection.type == ProviderBookingItemType.services) {
      detailsCubit.toggleService(uuid);
      await detailsCubit.startServiceBooking();
      if (employeeUuid != null) {
        await detailsCubit.chooseEmployee(employeeUuid);
      }
    } else if (selection.type == ProviderBookingItemType.packages) {
      await detailsCubit.startPackageBooking(uuid);
    } else if (selection.type == ProviderBookingItemType.ownedPackages) {
      await detailsCubit.startOwnedPackageBooking(
        entitlementUuid: item!.uuid,
        packageUuid: item.packageUuid ?? item.uuid,
      );
    } else {
      await detailsCubit.startFollowUpBooking(
        entitlementUuid: item!.uuid,
        serviceUuid: item.serviceUuid!,
      );
    }
  }

  ProviderBookingEntitlementModel? _selectedEntitlement(
    ProviderBookingItemsState selection,
    String uuid,
  ) {
    final items = selection.type == ProviderBookingItemType.ownedPackages
        ? selection.entitlements?.packages
        : selection.entitlements?.followUps;
    if (items == null) return null;
    for (final item in items) {
      if (item.uuid == uuid) return item;
    }
    return null;
  }
}
