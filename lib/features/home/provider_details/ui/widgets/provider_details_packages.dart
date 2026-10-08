import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsPackages extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsPackages({super.key, required this.state});

  @override
  Widget build(BuildContext context) => state.provider.packages.isEmpty
      ? Padding(
          padding: const EdgeInsets.only(top: 24),
          child: PdCard(
            radius: 24,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const PdIcon('ea57a'),
                const SizedBox(height: 18),
                Text(
                  pd(context, 'emptyPackages'),
                  style: pdText(20, pdInk, FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  pd(context, 'emptyPackagesHint'),
                  textAlign: TextAlign.center,
                  style: pdText(12, pdSub),
                ),
                const SizedBox(height: 16),
                PdButton(
                  pd(context, 'viewServices'),
                  onPressed: () => context
                      .read<ProviderDetailsCubit>()
                      .selectTab(ProviderDetailsTab.services),
                ),
              ],
            ),
          ),
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PdHeading(
              pd(context, 'packagesTitle'),
              pd(context, 'packagesCount', [
                state.provider.packages.length.toString(),
              ]),
            ),
            for (final package in state.provider.packages)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PdCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.name,
                              style: pdText(16, pdInk, FontWeight.w600),
                            ),
                            Text(
                              pd(context, 'packageMeta', [
                                package.sessions.toString(),
                                _money(package.price),
                              ]),
                              style: pdText(12, pdSub),
                            ),
                            if (package.description != null)
                              Text(
                                package.description!,
                                style: pdText(12, pdSub),
                              ),
                          ],
                        ),
                      ),
                      const PdIcon('ea57a'),
                    ],
                  ),
                ),
              ),
          ],
        );
}

String _money(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
