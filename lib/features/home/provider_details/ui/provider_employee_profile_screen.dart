import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/home/subcategories/ui/widgets/subcategories_app_bar.dart';

import '../data/models/provider_details_model.dart';
import '../logic/provider_employee_profile_cubit.dart';
import '../logic/provider_employee_profile_state.dart';
import 'widgets/provider_details_shared.dart';

class ProviderEmployeeProfileScreen extends StatelessWidget {
  final String employeeUuid;

  const ProviderEmployeeProfileScreen({super.key, required this.employeeUuid});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProviderEmployeeProfileCubit, ProviderEmployeeProfileState>(
        builder: (context, state) {
          final employee = state is ProviderEmployeeProfileLoaded
              ? state.employee
              : null;
          return Scaffold(
            backgroundColor: AppColors.pageColor,
            appBar: SubcategoriesAppBar(
              title: context.tr('providerPage.employeeProfileTitle'),
            ),
            bottomNavigationBar: employee == null
                ? null
                : _BookingBar(employee: employee),
            body: SafeArea(
              child: switch (state) {
                ProviderEmployeeProfileLoaded() => _ProfileBody(
                  employee: state.employee,
                ),
                ProviderEmployeeProfileNotFound() => _ProfileMessage(
                  message: context.tr('providerPage.employeeNotFound'),
                ),
                ProviderEmployeeProfileError() => _ProfileMessage(
                  message: state.message.trim().isEmpty
                      ? context.tr('providerPage.employeeLoadError')
                      : state.message,
                  actionLabel: context.tr('providerPage.retry'),
                  onAction: context.read<ProviderEmployeeProfileCubit>().load,
                ),
                _ => const _EmployeeProfileShimmer(),
              },
            ),
          );
        },
      );
}

class _ProfileBody extends StatelessWidget {
  final ProviderEmployeeProfileModel employee;
  const _ProfileBody({required this.employee});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EmployeeIdentity(employee: employee),
        const SizedBox(height: 16),
        _EmployeeStats(employee: employee),
        const SizedBox(height: 12),
        if (employee.services.isEmpty)
          PdNote(pd(context, 'employeeNoServices'))
        else
          _ServicesCard(services: employee.services),
        if (employee.services.any(_hasCustomPrice)) ...[
          const SizedBox(height: 14),
          const _PricingNote(),
        ],
      ],
    ),
  );
}

class _EmployeeIdentity extends StatelessWidget {
  final ProviderEmployeeProfileModel employee;
  const _EmployeeIdentity({required this.employee});

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      employee.jobTitle,
      employee.providerName,
      employee.branchName,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' · ');
    final photoUrl = employee.photoUrl?.trim();
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: pdInk.withValues(alpha: .18),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipOval(
            child: photoUrl == null || photoUrl.isEmpty
                ? _InitialAvatar(name: employee.name)
                : Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _InitialAvatar(name: employee.name),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          employee.name,
          textAlign: TextAlign.center,
          style: pdText(20, pdInk, FontWeight.w600),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: pdText(12, pdSub)),
        ],
      ],
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  const _InitialAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    return ColoredBox(
      color: const Color(0xFFD1F0F9),
      child: Center(
        child: Text(
          trimmed.isEmpty ? '?' : trimmed.characters.first,
          style: pdText(32, const Color(0xFF0C4D6E), FontWeight.w600),
        ),
      ),
    );
  }
}

class _EmployeeStats extends StatelessWidget {
  final ProviderEmployeeProfileModel employee;
  const _EmployeeStats({required this.employee});

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _StatTile(
            value: employee.rating == null
                ? pd(context, 'newRating')
                : employee.rating!.toStringAsFixed(1),
            label: pd(context, 'employeeRating'),
            highlighted: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: employee.ratingCount.toString(),
            label: pd(context, 'employeeReviews'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: employee.servicesCount.toString(),
            label: pd(context, 'employeeServicesCount'),
          ),
        ),
      ],
    ),
  );
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final bool highlighted;

  const _StatTile({
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 72),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: BoxDecoration(
      color: highlighted ? const Color(0xFFFFF6E0) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: highlighted
          ? null
          : Border.all(color: pdInk.withValues(alpha: .06)),
      boxShadow: highlighted
          ? null
          : [
              BoxShadow(
                color: pdInk.withValues(alpha: .08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: pdText(
              20,
              highlighted ? const Color(0xFF956321) : pdInk,
              FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: pdText(12, highlighted ? const Color(0xFF956321) : pdSub),
        ),
      ],
    ),
  );
}

class _ServicesCard extends StatelessWidget {
  final List<ProviderServiceModel> services;
  const _ServicesCard({required this.services});

  @override
  Widget build(BuildContext context) => PdCard(
    radius: 20,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          pd(context, 'employeeServicesAndPrices'),
          style: pdText(16, pdInk, FontWeight.w600),
        ),
        for (final service in services)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: pdText(16, pdInk, FontWeight.w600),
                      ),
                      if (service.durationMinutes != null)
                        Text(
                          pd(context, 'minutes', [
                            service.durationMinutes.toString(),
                          ]),
                          style: pdText(12, pdSub),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      pd(context, 'money', [_money(service.price)]),
                      style: pdText(16, pdInk, FontWeight.w600),
                    ),
                    if (_hasCustomPrice(service))
                      Text(
                        pd(context, 'branchBasePrice', [
                          _money(service.basePrice!),
                        ]),
                        style: pdText(11, pdSub),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _PricingNote extends StatelessWidget {
  const _PricingNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: pdPlate,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PdIcon('c02dd'),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            pd(context, 'employeePricingNote'),
            style: pdText(12, pdSub),
          ),
        ),
      ],
    ),
  );
}

class _BookingBar extends StatelessWidget {
  final ProviderEmployeeProfileModel employee;
  const _BookingBar({required this.employee});

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.pageColor.withValues(alpha: .96),
        border: Border(top: BorderSide(color: pdInk.withValues(alpha: .06))),
      ),
      child: FilledButton(
        onPressed: () => Navigator.of(context).pushNamed(
          Routes.providerBookingScreen,
          arguments: {
            'provider_uuid': employee.providerUuid,
            'provider_name': employee.providerName,
            'branch_uuid': employee.branchUuid,
            'employee_uuid': employee.uuid,
          },
        ),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: pdInk,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        child: Text(
          pd(context, 'bookWithEmployee', [employee.name]),
          style: pdText(16, Colors.white, FontWeight.w600),
        ),
      ),
    ),
  );
}

class _ProfileMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ProfileMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: pdText(16)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            PdButton(actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    ),
  );
}

class _EmployeeProfileShimmer extends StatelessWidget {
  const _EmployeeProfileShimmer();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFE8E8E4),
    highlightColor: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const _ShimmerBox(width: 96, height: 96, radius: 48),
          const SizedBox(height: 14),
          const _ShimmerBox(width: 150, height: 24),
          const SizedBox(height: 8),
          const _ShimmerBox(width: 240, height: 18),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _ShimmerBox(height: 74)),
              SizedBox(width: 10),
              Expanded(child: _ShimmerBox(height: 74)),
              SizedBox(width: 10),
              Expanded(child: _ShimmerBox(height: 74)),
            ],
          ),
          const SizedBox(height: 14),
          const _ShimmerBox(height: 240),
        ],
      ),
    ),
  );
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height, radius;
  const _ShimmerBox({this.width, required this.height, this.radius = 18});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

bool _hasCustomPrice(ProviderServiceModel service) =>
    service.basePrice != null && service.basePrice != service.price;

String _money(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
