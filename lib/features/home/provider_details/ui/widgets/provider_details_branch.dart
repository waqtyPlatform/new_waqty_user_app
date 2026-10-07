import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsBranch extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsBranch({super.key, required this.state});
  @override
  Widget build(BuildContext context) => PdCard(
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
                pd(context, state.branch.label),
                style: pdText(16, pdInk, FontWeight.w600),
              ),
              Text(pd(context, 'branchHint'), style: pdText(12, pdSub)),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            final cubit = context.read<ProviderDetailsCubit>();
            pdSheet(
              context,
              pd(context, 'change'),
              Column(
                children: [
                  PdNote(pd(context, 'branchReset')),
                  for (var i = 0; i < state.catalog.branches.length; i++)
                    ListTile(
                      title: Text(
                        pd(context, state.catalog.branches[i].label),
                        style: pdText(16),
                      ),
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
