import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsBranch extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsBranch({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final branch = state.branch;
    if (branch == null) return const SizedBox.shrink();
    final distance = branch.distanceKm == null
        ? ''
        : ' · ${branch.distanceKm!.toStringAsFixed(1)} ${pd(context, 'km')}';
    return PdCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: pdSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: PdIcon('8f50a')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${branch.name}$distance',
                  style: pdText(16, pdInk, FontWeight.w600),
                ),
                if (branch.displayAddress.isNotEmpty)
                  Text(
                    branch.displayAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pdText(12, pdSub),
                  ),
              ],
            ),
          ),
          if (state.provider.branches.length > 1)
            TextButton(
              onPressed: () {
                final cubit = context.read<ProviderDetailsCubit>();
                pdSheet(
                  context,
                  pd(context, 'change'),
                  Column(
                    children: [
                      PdNote(pd(context, 'branchReset')),
                      for (var i = 0; i < state.provider.branches.length; i++)
                        ListTile(
                          title: Text(
                            state.provider.branches[i].name,
                            style: pdText(16),
                          ),
                          subtitle:
                              state.provider.branches[i].displayAddress.isEmpty
                              ? null
                              : Text(state.provider.branches[i].displayAddress),
                          trailing: state.branchIndex == i
                              ? const Icon(Icons.check_circle, color: pdGreen)
                              : null,
                          onTap: () {
                            cubit.selectBranch(i);
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                );
              },
              child: Text(pd(context, 'change'), style: pdText(12, pdGreen)),
            ),
        ],
      ),
    );
  }
}
