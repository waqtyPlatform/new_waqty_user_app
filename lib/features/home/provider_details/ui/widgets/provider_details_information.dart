import 'package:flutter/material.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_header.dart';
import 'provider_details_shared.dart';

class ProviderDetailsInformation extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsInformation({super.key, required this.state});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PdHeading(pd(context, 'informationTitle'), pd(context, 'infoHint')),
      PdCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pd(context, 'hours'),
              style: pdText(16, pdInk, FontWeight.w600),
            ),
            const SizedBox(height: 8),
            for (final day in ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pd(context, day),
                        style: pdText(12, day == 'fri' ? pdSub : pdInk),
                      ),
                    ),
                    Text(
                      pd(context, day == 'fri' ? 'closed' : 'hoursValue'),
                      style: pdText(12, day == 'fri' ? pdSub : pdInk),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      InkWell(
        onTap: () => pdSheet(
          context,
          pd(context, 'ratedVisits', [state.provider.reviewsCount.toString()]),
          Text(pd(context, 'noReviews'), style: pdText(14, pdSub)),
        ),
        child: PdCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.provider.rating.toStringAsFixed(1),
                      style: pdText(14, pdInk, FontWeight.w600),
                    ),
                    const PdIcon('bc188'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pd(context, 'ratedVisits', [
                        state.provider.reviewsCount.toString(),
                      ]),
                      style: pdText(14),
                    ),
                    Text(pd(context, 'reviewHint'), style: pdText(11, pdSub)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, size: 16, color: pdSub),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),
      PdCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: pdSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: PdIcon('2fe1b')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pd(context, 'payment'),
                    style: pdText(14, pdInk, FontWeight.w600),
                  ),
                  Text(pd(context, 'paymentHint'), style: pdText(11, pdSub)),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      PdCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pd(context, 'policies'),
              style: pdText(16, pdInk, FontWeight.w600),
            ),
            for (final policy in [
              'before',
              'cancel',
              'refund',
              'noShow',
              'prepare',
            ])
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: PageStorageKey('policy-$policy'),
                  initiallyExpanded: policy == 'cancel',
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 12),
                  title: Text(pd(context, policy), style: pdText(14)),
                  children: [
                    Text(
                      pd(
                        context,
                        policy == 'cancel' ? 'cancelBody' : 'policyPending',
                      ),
                      style: pdText(12, pdSub),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      InkWell(
        onTap: () => showProviderAddress(context, state),
        child: PdCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: PdIcon('95387')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pd(context, state.branch.address), style: pdText(14)),
                    Text(pd(context, 'mapHint'), style: pdText(11, pdGreen)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, size: 16, color: pdSub),
            ],
          ),
        ),
      ),
    ],
  );
}
