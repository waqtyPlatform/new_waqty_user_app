import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_booking_bar.dart';
import 'provider_details_shared.dart';

class ProviderDetailsSpecialists extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsSpecialists({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderDetailsCubit>();
    final employees = state.provider.employees;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PdHeading(
          pd(context, 'specialistsTitle'),
          employees.isEmpty
              ? pd(context, 'unnamedHint')
              : pd(context, 'specialistsHint', [employees.length.toString()]),
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
                          employees.isEmpty ? 'unnamedDescription' : 'anyHint',
                        ),
                        style: pdText(
                          12,
                          state.specialistId == null ? Colors.white60 : pdSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final employee in employees)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => cubit.selectSpecialist(employee.uuid),
              child: PdCard(
                color: state.specialistId == employee.uuid
                    ? pdSoft
                    : Colors.white,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: pdSoft,
                      backgroundImage: employee.photoUrl == null
                          ? null
                          : NetworkImage(employee.photoUrl!),
                      child: employee.photoUrl == null
                          ? Text(
                              employee.name.isEmpty
                                  ? '?'
                                  : employee.name.characters.first,
                              style: pdText(20, pdGreen),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: pdText(16, pdInk, FontWeight.w600),
                          ),
                          if (employee.jobTitle != null)
                            Text(employee.jobTitle!, style: pdText(12, pdSub)),
                        ],
                      ),
                    ),
                    Icon(
                      state.specialistId == employee.uuid
                          ? Icons.check_circle
                          : Icons.chevron_left,
                      size: 18,
                      color: state.specialistId == employee.uuid
                          ? pdGreen
                          : pdSub,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (employees.isEmpty) ...[
          PdNote(pd(context, 'unnamedDescription'), green: true),
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
