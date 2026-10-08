import 'package:flutter/material.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsSpecialists extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsSpecialists({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final employees = state.provider.employees;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PdHeading(
          pd(context, 'specialistsTitle'),
          employees.isEmpty
              ? pd(context, 'unnamedHint')
              : pd(context, 'specialistsCount', [employees.length.toString()]),
        ),
        for (final employee in employees)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PdCard(
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
                ],
              ),
            ),
          ),
        if (employees.isEmpty) PdNote(pd(context, 'unnamedDescription')),
      ],
    );
  }
}
