import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsSpecialists extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsSpecialists({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final employees = state.availableEmployees;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PdHeading(
          pd(context, 'specialistsTitle'),
          employees.isEmpty
              ? pd(context, 'unnamedHint')
              : pd(context, 'specialistsCount', [employees.length.toString()]),
        ),
        if (employees.isNotEmpty)
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: employees.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final employee = employees[index];
                return SizedBox(
                  width: 86,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pushNamed(
                      Routes.providerEmployeeScreen,
                      arguments: {'employee_uuid': employee.uuid},
                    ),
                    child: Column(
                      children: [
                        _EmployeeAvatar(
                          name: employee.name,
                          photoUrl: employee.photoUrl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          employee.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: pdText(13, pdInk, FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (employees.isEmpty) PdNote(pd(context, 'unnamedDescription')),
      ],
    );
  }
}

class _EmployeeAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const _EmployeeAvatar({required this.name, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    return Container(
      width: 64,
      height: 64,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: pdSoft),
      child: url == null || url.isEmpty
          ? _initial()
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initial(),
            ),
    );
  }

  Widget _initial() {
    final trimmedName = name.trim();
    return Center(
      child: Text(
        trimmedName.isEmpty ? '?' : trimmedName.characters.first,
        style: pdText(24, pdGreen, FontWeight.w600),
      ),
    );
  }
}
