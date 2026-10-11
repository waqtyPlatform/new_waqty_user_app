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
        SizedBox(
          height: 156,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.availableServices.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 230,
              child: _ServiceTile(service: state.availableServices[index]),
            ),
          ),
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
        ? null
        : pd(context, 'minutes', [service.durationMinutes.toString()]);
    return PdCard(
      color: Colors.white,
      radius: 20,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => pdSheet(
          context,
          service.name,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (service.description != null)
                Text(service.description!, style: pdText(14, pdSub)),
              Text(
                duration == null ? price : '$price · $duration',
                style: pdText(16),
              ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: pdSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.design_services_outlined,
                      size: 18,
                      color: pdGreen,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: pdInk.withValues(alpha: .06)),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      size: 18,
                      color: pdSub,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                service.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pdText(16, pdInk, FontWeight.w600),
              ),
              if (service.subcategory != null)
                Text(
                  service.subcategory!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pdText(11, pdSub),
                ),
              const Spacer(),
              Row(
                children: [
                  Text(price, style: pdText(13, pdInk, FontWeight.w600)),
                  if (duration != null) ...[
                    const Spacer(),
                    Text(duration, style: pdText(12, pdSub)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _money(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
