import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsPackages extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsPackages({super.key, required this.state});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: PdCard(
      radius: 24,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: pdPlate,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: PdIcon('ea57a')),
          ),
          const SizedBox(height: 18),
          Text(
            pd(context, 'emptyPackages'),
            textAlign: TextAlign.center,
            style: pdText(20, pdInk, FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            pd(context, 'emptyPackagesHint'),
            textAlign: TextAlign.center,
            style: pdText(12, pdSub),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PdButton(
              pd(context, 'viewServices'),
              onPressed: () => context.read<ProviderDetailsCubit>().selectTab(
                ProviderDetailsTab.services,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
