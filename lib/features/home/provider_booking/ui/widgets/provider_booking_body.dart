import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/provider_details/data/models/provider_details_model.dart';

import '../../data/models/provider_booking_items_model.dart';
import '../../logic/provider_booking_items_cubit.dart';
import '../../logic/provider_booking_items_state.dart';
import 'provider_booking_components.dart';

class ProviderBookingBody extends StatelessWidget {
  final String providerName;
  final ProviderBookingItemsState state;
  final VoidCallback onContinue;

  const ProviderBookingBody({
    super.key,
    required this.providerName,
    required this.state,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('providerBooking.addItems'),
              style: TextStyles.font20greyColor900W600,
            ),
            if (providerName.trim().isNotEmpty)
              Text(providerName, style: TextStyles.font12greyColor500W400),
          ],
        ),
      ),
      ProviderBookingTypeSelector(
        selected: state.type,
        onChanged: context.read<ProviderBookingItemsCubit>().selectType,
      ),
      const Divider(height: 1, color: AppColors.greyColor50),
      Expanded(child: _content(context)),
      ProviderBookingContinueBar(
        enabled: state.selectedUuid != null && !state.loading,
        loading: state.continuing,
        onPressed: onContinue,
      ),
    ],
  );

  Widget _content(BuildContext context) {
    if (state.loading) return const ProviderBookingItemsShimmer();
    if (state.error != null) {
      return _refreshable(
        context,
        ProviderBookingMessageState(
          icon: Icons.error_outline_rounded,
          title: state.error!.trim().isEmpty
              ? context.tr('providerBooking.loadError')
              : state.error!,
          action: context.tr('providerBooking.retry'),
          onAction: context.read<ProviderBookingItemsCubit>().load,
        ),
      );
    }
    return switch (state.type) {
      ProviderBookingItemType.services => _services(context),
      ProviderBookingItemType.packages => _packages(context),
      ProviderBookingItemType.ownedPackages => _entitlements(
        context,
        state.entitlements?.packages ?? const [],
        emptyKey: 'providerBooking.noOwnedPackages',
        icon: Icons.card_membership_outlined,
      ),
      ProviderBookingItemType.followUps => _entitlements(
        context,
        state.entitlements?.followUps ?? const [],
        emptyKey: 'providerBooking.noFollowUps',
        icon: Icons.event_repeat_rounded,
      ),
    };
  }

  Widget _services(BuildContext context) {
    final services =
        state.catalogue?.services ?? const <ProviderServiceModel>[];
    if (services.isEmpty) {
      return _refreshable(
        context,
        ProviderBookingMessageState(
          icon: Icons.content_cut_rounded,
          title: context.tr('providerBooking.noServices'),
        ),
      );
    }
    return _choiceList(
      context,
      services.map(
        (service) => ProviderBookingChoiceCard(
          title: service.name,
          subtitle: service.description,
          meta: '',
          selected: state.selectedUuid == service.uuid,
          onTap: () => context.read<ProviderBookingItemsCubit>().selectItem(
            service.uuid,
          ),
        ),
      ),
    );
  }

  Widget _packages(BuildContext context) {
    final packages =
        state.catalogue?.packages ?? const <ProviderPackageModel>[];
    if (packages.isEmpty) {
      return _refreshable(
        context,
        ProviderBookingMessageState(
          icon: Icons.inventory_2_outlined,
          title: context.tr('providerBooking.noOffers'),
        ),
      );
    }
    return _choiceList(
      context,
      packages.map(
        (package) => ProviderBookingChoiceCard(
          title: package.name,
          subtitle: package.description,
          meta: _packageMeta(context, package),
          selected: state.selectedUuid == package.uuid,
          onTap: () => context.read<ProviderBookingItemsCubit>().selectItem(
            package.uuid,
          ),
        ),
      ),
    );
  }

  Widget _entitlements(
    BuildContext context,
    List<ProviderBookingEntitlementModel> items, {
    required String emptyKey,
    required IconData icon,
  }) {
    if (items.isEmpty) {
      return _refreshable(
        context,
        ProviderBookingMessageState(icon: icon, title: context.tr(emptyKey)),
      );
    }
    return _choiceList(
      context,
      items.map(
        (item) => ProviderBookingChoiceCard(
          title: item.name.isEmpty
              ? context.tr('providerBooking.entitlementFallback')
              : item.name,
          subtitle: item.description,
          meta: _entitlementMeta(context, item),
          selected: state.selectedUuid == item.uuid,
          onTap: () =>
              context.read<ProviderBookingItemsCubit>().selectItem(item.uuid),
        ),
      ),
    );
  }

  Widget _choiceList(BuildContext context, Iterable<Widget> cards) {
    final items = cards.toList(growable: false);
    return RefreshIndicator(
      onRefresh: context.read<ProviderBookingItemsCubit>().refresh,
      color: AppColors.greenColor500,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => items[index],
      ),
    );
  }

  Widget _refreshable(BuildContext context, Widget message) => RefreshIndicator(
    onRefresh: context.read<ProviderBookingItemsCubit>().refresh,
    color: AppColors.greenColor500,
    child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: message)],
    ),
  );

  String _packageMeta(BuildContext context, ProviderPackageModel package) {
    final quantity = switch (package.type) {
      ProviderPackageType.multiSession => context.tr(
        'providerBooking.sessions',
        args: [package.sessions.toString()],
      ),
      ProviderPackageType.creditUnits => context.tr(
        'providerBooking.units',
        args: [package.units.toString(), package.unitName ?? ''],
      ),
      ProviderPackageType.singleVisit => context.tr(
        'providerBooking.singleVisit',
      ),
      ProviderPackageType.unknown => '',
    };
    return [
      if (quantity.isNotEmpty) quantity,
      _money(package.price, package.currencyCode),
    ].join(' · ');
  }

  String _entitlementMeta(
    BuildContext context,
    ProviderBookingEntitlementModel item,
  ) {
    final parts = <String>[
      if (item.remainingSessions != null)
        context.tr(
          'providerBooking.remainingSessions',
          args: [item.remainingSessions.toString()],
        ),
      if (item.remainingUnits != null)
        context.tr(
          'providerBooking.remainingUnits',
          args: [item.remainingUnits.toString(), item.unitName ?? ''],
        ),
      if (item.remainingVisits != null)
        context.tr(
          'providerBooking.remainingVisits',
          args: [item.remainingVisits.toString()],
        ),
      if (item.expiresAt != null)
        context.tr('providerBooking.expiresAt', args: [item.expiresAt!]),
    ];
    return parts.join(' · ');
  }

  String _money(double value, String? currencyCode) {
    final amount = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$amount ${currencyCode ?? ''}'.trim();
  }
}
