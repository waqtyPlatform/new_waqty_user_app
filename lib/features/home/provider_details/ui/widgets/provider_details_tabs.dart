import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsTabs extends StatelessWidget {
  final ProviderDetailsTab selected;
  const ProviderDetailsTabs({super.key, required this.selected});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 14, bottom: 10),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: pdPlate,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      children: [
        for (final tab in ProviderDetailsTab.values)
          Expanded(
            child: Semantics(
              selected: tab == selected,
              button: true,
              child: Material(
                color: selected == tab ? pdInk : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  key: ValueKey('tab-${tab.name}'),
                  borderRadius: BorderRadius.circular(999),
                  onTap: () =>
                      context.read<ProviderDetailsCubit>().selectTab(tab),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 9,
                    ),
                    child: Text(
                      pd(context, tab.name),
                      textAlign: TextAlign.center,
                      style: pdText(12, selected == tab ? Colors.white : pdSub),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
