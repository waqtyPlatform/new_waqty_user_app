import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import '../data/models/provider_details_model.dart';
import '../logic/provider_details_cubit.dart';
import '../logic/provider_details_state.dart';
import 'widgets/provider_details_header.dart';
import 'widgets/provider_details_branch.dart';
import 'widgets/provider_details_tabs.dart';
import 'widgets/provider_details_services.dart';
import 'widgets/provider_details_specialists.dart';
import 'widgets/provider_details_packages.dart';
import 'widgets/provider_details_information.dart';
import 'widgets/provider_details_booking_bar.dart';
import 'widgets/provider_details_shimmer.dart';
import 'widgets/provider_details_shared.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final ProviderDetailsModel provider;
  const ProviderDetailsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProviderDetailsCubit, ProviderDetailsState>(
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.pageColor,
          bottomNavigationBar: state is ProviderDetailsLoaded
              ? ProviderDetailsBookingBar(state: state)
              : null,
          body: state is ProviderDetailsLoaded
              ? CustomScrollView(
                  key: const PageStorageKey('provider-details-scroll'),
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
                            ProviderDetailsTabs(selected: state.tab),
                            switch (state.tab) {
                              ProviderDetailsTab.services =>
                                ProviderDetailsServices(state: state),
                              ProviderDetailsTab.specialists =>
                                ProviderDetailsSpecialists(state: state),
                              ProviderDetailsTab.packages =>
                                ProviderDetailsPackages(state: state),
                              ProviderDetailsTab.information =>
                                ProviderDetailsInformation(state: state),
                            },
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : state is ProviderDetailsError
              ? SafeArea(
                  child: Column(
                    children: [
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: BackButton(),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(pd(context, 'loadError'), style: pdText(18)),
                              PdButton(
                                pd(context, 'retry'),
                                onPressed: () => context
                                    .read<ProviderDetailsCubit>()
                                    .initialize(provider),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const ProviderDetailsShimmer(),
        ),
      );
}
