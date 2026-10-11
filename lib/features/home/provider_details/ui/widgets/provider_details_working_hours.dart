import 'package:flutter/material.dart';
import '../../data/models/provider_details_model.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsWorkingHours extends StatelessWidget {
  final ProviderDetailsLoaded state;

  const ProviderDetailsWorkingHours({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hours = {
      for (final item
          in state.branch?.workingHours ?? const <ProviderWorkingHourModel>[])
        item.dayOfWeek: item,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PdHeading(pd(context, 'hours'), pd(context, 'hoursHint')),
        PdCard(
          child: Column(
            children: [
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
                        child: Text(pd(context, entry.$2), style: pdText(13)),
                      ),
                      Text(
                        hours[entry.$1] == null
                            ? pd(context, 'closed')
                            : '${_time(hours[entry.$1]!.startTime)} – ${_time(hours[entry.$1]!.endTime)}',
                        style: pdText(
                          13,
                          hours[entry.$1] == null ? pdSub : pdInk,
                          hours[entry.$1] == null
                              ? FontWeight.w400
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String _time(String value) => value.length >= 5 ? value.substring(0, 5) : value;
