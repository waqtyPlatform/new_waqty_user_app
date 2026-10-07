import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';
import 'provider_details_booking_bar.dart';

class ProviderDetailsSpecialists extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsSpecialists({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderDetailsCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PdHeading(
          pd(context, 'specialistsTitle'),
          state.branch.namedStaff
              ? pd(context, 'specialistsHint', [
                  state.branch.specialists.length.toString(),
                ])
              : pd(context, 'unnamedHint'),
        ),
        InkWell(
          onTap: () => cubit.selectSpecialist(null),
          child: PdCard(
            color: state.specialistId == null ? pdInk : Colors.white,
            outlined: false,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: state.specialistId == null
                      ? const Color(0xFF27272D)
                      : pdSoft,
                  radius: 24,
                  child: const PdIcon('cad0b'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pd(context, 'anySpecialist'),
                        style: pdText(
                          16,
                          state.specialistId == null ? Colors.white : pdInk,
                        ),
                      ),
                      Text(
                        pd(
                          context,
                          state.branch.namedStaff
                              ? 'anyHint'
                              : 'unnamedDescription',
                        ),
                        style: pdText(
                          12,
                          state.specialistId == null ? Colors.white60 : pdSub,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.branch.namedStaff)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: Text(
                      pd(context, 'recommended'),
                      style: pdText(10, const Color(0xFF8EE4B4)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (state.branch.namedStaff) ...[
          for (final specialist in state.branch.specialists)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => cubit.selectSpecialist(specialist.id),
                child: PdCard(
                  color: state.specialistId == specialist.id
                      ? pdSoft
                      : Colors.white,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: pdSoft,
                        child: Text(
                          pd(context, specialist.label).substring(0, 1),
                          style: pdText(20, pdGreen),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pd(context, specialist.label),
                              style: pdText(16, pdInk, FontWeight.w600),
                            ),
                            Text(
                              pd(context, 'fromPrice', [
                                specialist.price.toString(),
                                specialist.minutes.toString(),
                              ]),
                              style: pdText(12, pdSub),
                            ),
                            if (specialist.recommended)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF6E0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  pd(context, 'specialistBadge'),
                                  style: pdText(11, const Color(0xFF956321)),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        state.specialistId == specialist.id
                            ? Icons.check_circle
                            : Icons.chevron_left,
                        size: 18,
                        color: state.specialistId == specialist.id
                            ? pdGreen
                            : pdSub,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          PdNote(pd(context, 'specialistNote')),
        ] else ...[
          PdNote(pd(context, 'noFee'), green: true),
          const SizedBox(height: 14),
          PdCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pd(context, 'bookingMeaning'),
                  style: pdText(16, pdInk, FontWeight.w600),
                ),
                for (var index = 1; index <= 3; index++)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: pdSoft,
                          child: Text('$index', style: pdText(12, pdGreen)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pd(context, 'step$index'),
                            style: pdText(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PdButton(
            pd(context, 'chooseTime'),
            onPressed: () => showBookingSummary(context, state),
          ),
        ],
      ],
    );
  }
}
