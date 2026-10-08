import 'package:flutter/material.dart';
import '../../data/models/provider_details_model.dart';
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
          state.availableServices.length.toString(),
        ]),
      ),
      if (state.availableServices.isEmpty)
        PdNote(pd(context, 'noServices'))
      else
        for (final service in state.availableServices)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ServiceTile(service: service),
          ),
    ],
  );
}

class _ServiceTile extends StatelessWidget {
  final ProviderServiceModel service;
  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
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
            const Icon(Icons.chevron_left, size: 18, color: pdSub),
          ],
        ),
      ),
    );
  }
}

String _money(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
