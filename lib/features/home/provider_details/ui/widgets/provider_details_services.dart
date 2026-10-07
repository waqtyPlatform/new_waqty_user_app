import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/provider_details_model.dart';
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
        pd(context, 'servicesHint', [state.provider.servicesCount.toString()]),
      ),
      if (state.provider.services.isEmpty)
        PdNote(pd(context, 'noServices'))
      else
        for (final service in state.provider.services)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ProviderServiceTile(service: service, state: state),
          ),
    ],
  );
}

class ProviderServiceTile extends StatelessWidget {
  final ProviderServiceModel service;
  final ProviderDetailsLoaded state;
  const ProviderServiceTile({
    super.key,
    required this.service,
    required this.state,
  });
  @override
  Widget build(BuildContext context) {
    final selected = state.selectedIds.contains(service.uuid);
    final price = service.priceMax != service.price
        ? pd(context, 'priceRange', [
            _money(service.price),
            _money(service.priceMax),
          ])
        : pd(context, 'money', [_money(service.price)]);
    final duration = service.durationMinutes == null
        ? ''
        : ' · ${pd(context, 'minutes', [service.durationMinutes.toString()])}';
    return PdCard(
      color: selected ? pdSoft : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => pdSheet(
                context,
                service.name,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (service.description != null)
                      Text(service.description!, style: pdText(14, pdSub)),
                    Text('$price$duration', style: pdText(16)),
                    if (service.branchesCount > 0)
                      Text(
                        pd(context, 'availableBranches', [
                          service.branchesCount.toString(),
                        ]),
                        style: pdText(12, pdSub),
                      ),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: pdText(16, pdInk, FontWeight.w600)),
                  Text('$price$duration', style: pdText(12, pdSub)),
                  if (service.subcategory != null)
                    Text(service.subcategory!.name, style: pdText(11, pdSub)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: selected ? pdGreen : Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              key: ValueKey('service-${service.uuid}'),
              tooltip: pd(context, selected ? 'remove' : 'add'),
              onPressed: () => context
                  .read<ProviderDetailsCubit>()
                  .toggleService(service.uuid),
              icon: PdIcon(selected ? '95f6b' : '2dfe3'),
            ),
          ),
        ],
      ),
    );
  }
}

String _money(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
