import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/provider_catalog.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsServices extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsServices({super.key, required this.state});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PdHeading(
        pd(context, 'servicesTitle'),
        pd(context, 'servicesHint', [
          state.branch.services
              .fold<int>(
                0,
                (count, item) =>
                    count + (item.children.isEmpty ? 1 : item.children.length),
              )
              .toString(),
        ]),
      ),
      for (final service in state.branch.services)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ProviderServiceTile(service: service, state: state),
        ),
      const SizedBox(height: 4),
      PdNote(pd(context, 'serviceNote')),
    ],
  );
}

class ProviderServiceTile extends StatelessWidget {
  final ProviderServiceItem service;
  final ProviderDetailsLoaded state;
  const ProviderServiceTile({
    super.key,
    required this.service,
    required this.state,
  });
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderDetailsCubit>();
    final selected = state.selectedIds.contains(service.id);
    final group = service.children.isNotEmpty;
    void details() {
      if (group) {
        pdSheet(
          context,
          pd(context, service.label),
          BlocProvider.value(
            value: cubit,
            child: BlocBuilder<ProviderDetailsCubit, ProviderDetailsState>(
              builder: (context, updated) => Column(
                children: [
                  for (final child in service.children)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ProviderServiceTile(
                        service: child,
                        state: updated is ProviderDetailsLoaded
                            ? updated
                            : state,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      } else {
        pdSheet(
          context,
          pd(context, service.label),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                pd(context, 'serviceMeta', [
                  service.price.toString(),
                  service.minutes.toString(),
                ]),
                style: pdText(16),
              ),
              const SizedBox(height: 16),
              PdButton(
                pd(context, selected ? 'remove' : 'add'),
                onPressed: () {
                  cubit.toggleService(service.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    }

    return PdCard(
      outlined: group,
      color: selected ? pdSoft : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: details,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pd(context, service.label),
                    style: pdText(16, pdInk, FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    group
                        ? pd(context, 'groupMeta', [
                            service.children.length.toString(),
                            service.price.toString(),
                          ])
                        : pd(context, 'serviceMeta', [
                            service.price.toString(),
                            service.minutes.toString(),
                          ]),
                    style: pdText(12, pdSub),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (group)
            PdButton(pd(context, 'openGroup'), onPressed: details)
          else
            Material(
              color: selected ? pdGreen : Colors.white,
              shape: const CircleBorder(),
              child: IconButton(
                key: ValueKey('service-${service.id}'),
                tooltip: pd(context, selected ? 'remove' : 'add'),
                onPressed: () => cubit.toggleService(service.id),
                icon: PdIcon(selected ? '95f6b' : '2dfe3'),
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
