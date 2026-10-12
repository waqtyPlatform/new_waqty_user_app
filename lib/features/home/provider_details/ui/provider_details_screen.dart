import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import '../logic/provider_details_cubit.dart';
import '../logic/provider_details_state.dart';
import 'widgets/provider_details_booking_bar.dart';
import 'widgets/provider_details_branch.dart';
import 'widgets/provider_details_header.dart';
import 'widgets/provider_details_packages.dart';
import 'widgets/provider_details_policies.dart';
import 'widgets/provider_details_services.dart';
import 'widgets/provider_details_shared.dart';
import 'widgets/provider_details_shimmer.dart';
import 'widgets/provider_details_specialists.dart';
import 'widgets/provider_details_working_hours.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final String providerUuid;
  const ProviderDetailsScreen({super.key, required this.providerUuid});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProviderDetailsCubit, ProviderDetailsState>(
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.pageColor,
          bottomNavigationBar: state is ProviderDetailsLoaded
              ? ProviderDetailsBookingBar(state: state)
              : null,
          body: switch (state) {
            ProviderDetailsLoaded() => RefreshIndicator(
              color: pdGreen,
              onRefresh: () => context.read<ProviderDetailsCubit>().refresh(),
              child: CustomScrollView(
                key: const PageStorageKey('provider-details-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ProviderDetailsHeader(state: state),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProviderDetailsBranch(state: state),
                          ProviderDetailsServices(state: state),
                          ProviderDetailsPackages(state: state),
                          ProviderDetailsSpecialists(state: state),
                          ProviderDetailsWorkingHours(state: state),
                          ProviderDetailsPolicies(state: state),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ProviderDetailsNotFound() => _ProviderDetailsMessage(
              message: pd(context, 'providerNotFound'),
            ),
            ProviderDetailsError() => SafeArea(
              child: _ProviderDetailsMessage(
                message: pd(context, 'loadError'),
                action: PdButton(
                  pd(context, 'retry'),
                  onPressed: () =>
                      context.read<ProviderDetailsCubit>().load(providerUuid),
                ),
              ),
            ),
            _ => const ProviderDetailsShimmer(),
          },
        ),
      );
}

class _ProviderDetailsMessage extends StatelessWidget {
  final String message;
  final Widget? action;

  const _ProviderDetailsMessage({required this.message, this.action});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: BackButton(),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront_outlined, size: 56, color: pdSub),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: pdText(18, pdInk, FontWeight.w600),
                  ),
                  if (action != null) ...[const SizedBox(height: 20), action!],
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
