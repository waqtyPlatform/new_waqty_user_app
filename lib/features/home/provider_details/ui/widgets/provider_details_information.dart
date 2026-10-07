import 'package:flutter/material.dart';
import '../../data/models/provider_details_model.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_header.dart';
import 'provider_details_shared.dart';

class ProviderDetailsInformation extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsInformation({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final branch = state.branch;
    final hours = {
      for (final item
          in branch?.workingHours ?? const <ProviderWorkingHourModel>[])
        item.dayOfWeek: item,
    };
    return Column(
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
              for (final entry in const [
                (6, 'sat'),
                (0, 'sun'),
                (1, 'mon'),
                (2, 'tue'),
                (3, 'wed'),
                (4, 'thu'),
                (5, 'fri'),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(pd(context, entry.$2), style: pdText(12)),
                      ),
                      Text(
                        hours[entry.$1] == null
                            ? pd(context, 'closed')
                            : '${_time(hours[entry.$1]!.startTime)} – ${_time(hours[entry.$1]!.endTime)}',
                        style: pdText(
                          12,
                          hours[entry.$1] == null ? pdSub : pdInk,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _showReviews(context),
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
                  child: Center(
                    child: Text(
                      state.provider.rating == null
                          ? pd(context, 'newRating')
                          : state.provider.rating!.toStringAsFixed(1),
                      style: pdText(13, pdInk, FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pd(context, 'ratedVisits', [
                          state.provider.ratingCount.toString(),
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
        if (branch != null && branch.displayAddress.isNotEmpty)
          InkWell(
            onTap: () => openProviderMap(context, state),
            child: PdCard(
              child: Row(
                children: [
                  const PdIcon('95387'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(branch.displayAddress, style: pdText(14)),
                  ),
                  const Icon(Icons.chevron_left, size: 16, color: pdSub),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showReviews(BuildContext context) => pdSheet(
    context,
    pd(context, 'reviews'),
    state.provider.reviews.isEmpty
        ? Text(pd(context, 'noReviews'), style: pdText(14, pdSub))
        : Column(
            children: [
              for (final review in state.provider.reviews)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PdCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                review.userName ?? pd(context, 'anonymous'),
                                style: pdText(14, pdInk, FontWeight.w600),
                              ),
                            ),
                            Text('★ ${review.rating}', style: pdText(13)),
                          ],
                        ),
                        if (review.serviceName != null)
                          Text(review.serviceName!, style: pdText(11, pdSub)),
                        Text(review.comment, style: pdText(14)),
                        if (review.reply != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            pd(context, 'providerReply'),
                            style: pdText(12, pdGreen),
                          ),
                          Text(review.reply!, style: pdText(13, pdSub)),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
  );
}

String _time(String value) => value.length >= 5 ? value.substring(0, 5) : value;
