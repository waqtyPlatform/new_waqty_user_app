import 'package:flutter/material.dart';
import '../../data/models/provider_details_model.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsPolicies extends StatelessWidget {
  final ProviderDetailsLoaded state;

  const ProviderDetailsPolicies({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final policies = state.provider.policies;
    if (policies == null || !policies.hasContent) {
      return const SizedBox.shrink();
    }

    final items = <({IconData icon, String title, String body})>[
      if (policies.cancellation != null ||
          policies.cancellationWindowHours != null)
        (
          icon: Icons.event_busy_outlined,
          title: pd(context, 'cancel'),
          body:
              policies.cancellation ??
              pd(context, 'freeCancellationHours', [
                policies.cancellationWindowHours.toString(),
              ]),
        ),
      if (policies.refund != null)
        (
          icon: Icons.currency_exchange_outlined,
          title: pd(context, 'refund'),
          body: policies.refund!,
        ),
      if (policies.noShow != null || policies.noShowFee != null)
        (
          icon: Icons.person_off_outlined,
          title: pd(context, 'noShow'),
          body: _noShowText(context, policies),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PdHeading(pd(context, 'policies'), pd(context, 'policiesHint')),
        PdCard(
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                _PolicyRow(item: items[index]),
                if (index != items.length - 1)
                  const Divider(height: 25, color: Color(0xFFE8E8E5)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _noShowText(BuildContext context, ProviderPoliciesModel policies) {
    final policy = policies.noShow;
    final fee = policies.noShowFee;
    if (policy != null && fee != null) {
      return '$policy\n${pd(context, 'noShowFee', [_money(fee), state.provider.currencyCode ?? ''])}';
    }
    if (policy != null) return policy;
    return pd(context, 'noShowFee', [
      _money(fee!),
      state.provider.currencyCode ?? '',
    ]);
  }
}

class _PolicyRow extends StatelessWidget {
  final ({IconData icon, String title, String body}) item;

  const _PolicyRow({required this.item});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: pdSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, size: 20, color: pdGreen),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: pdText(14, pdInk, FontWeight.w600)),
            const SizedBox(height: 2),
            Text(item.body, style: pdText(12, pdSub)),
          ],
        ),
      ),
    ],
  );
}

String _money(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
