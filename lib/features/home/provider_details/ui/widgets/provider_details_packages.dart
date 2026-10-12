import 'package:flutter/material.dart';
import '../../data/models/provider_details_model.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsPackages extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsPackages({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final branchUuid = state.branch?.uuid;
    final packages = state.provider.packages
        .where(
          (package) =>
              package.branchUuid == null || package.branchUuid == branchUuid,
        )
        .toList(growable: false);
    return packages.isEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 24),
            child: PdCard(
              radius: 24,
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const PdIcon('ea57a'),
                  const SizedBox(height: 18),
                  Text(
                    pd(context, 'emptyPackages'),
                    style: pdText(20, pdInk, FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pd(context, 'emptyPackagesHint'),
                    textAlign: TextAlign.center,
                    style: pdText(12, pdSub),
                  ),
                ],
              ),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PdHeading(
                pd(context, 'packagesTitle'),
                pd(context, 'packagesCount', [packages.length.toString()]),
              ),
              SizedBox(
                height: 174,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: packages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return SizedBox(
                      width: 280,
                      child: PdCard(
                        padding: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _showPackageDetails(context, package),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package.name,
                                        style: pdText(
                                          16,
                                          pdInk,
                                          FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: pdSoft,
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
                                          ),
                                          child: Text(
                                            _typeLabel(context, package.type),
                                            style: pdText(
                                              10,
                                              pdGreen,
                                              FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _packageMeta(context, package),
                                        style: pdText(12, pdSub),
                                      ),
                                      if (package.includedServices.isNotEmpty)
                                        Text(
                                          _servicesSummary(package),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: pdText(
                                            12,
                                            pdInk,
                                            FontWeight.w500,
                                          ),
                                        )
                                      else if (package.description != null)
                                        Text(
                                          package.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: pdText(12, pdSub),
                                        ),
                                    ],
                                  ),
                                ),
                                const PdIcon('ea57a'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}

void _showPackageDetails(
  BuildContext context,
  ProviderPackageModel package,
) => pdSheet(
  context,
  package.name,
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _DetailChip(_typeLabel(context, package.type)),
          _DetailChip(_packageMeta(context, package), emphasized: true),
          if (package.validityDays > 0)
            _DetailChip(
              pd(context, 'packageValidityDays', [
                package.validityDays.toString(),
              ]),
            ),
          if (package.savings != null && package.savings! > 0)
            _DetailChip(
              pd(context, 'packageSavings', [_money(package.savings!)]),
            ),
        ],
      ),
      if (package.description != null) ...[
        const SizedBox(height: 16),
        Text(package.description!, style: pdText(14, pdSub)),
      ],
      if (package.includedServices.isNotEmpty) ...[
        const SizedBox(height: 18),
        Text(
          pd(context, 'packageIncludedServices'),
          style: pdText(16, pdInk, FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (final service in package.includedServices)
          if (service.serviceName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: pdGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(service.serviceName, style: pdText(14))),
                  if (service.sessions > 0)
                    Text(
                      pd(context, 'sessions', [service.sessions.toString()]),
                      style: pdText(12, pdSub),
                    ),
                ],
              ),
            ),
      ],
    ],
  ),
);

class _DetailChip extends StatelessWidget {
  final String label;
  final bool emphasized;

  const _DetailChip(this.label, {this.emphasized = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: emphasized ? pdInk : pdSoft,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: pdText(12, emphasized ? Colors.white : pdGreen, FontWeight.w500),
    ),
  );
}

String _servicesSummary(ProviderPackageModel package) => package
    .includedServices
    .where((item) => item.serviceName.isNotEmpty)
    .map(
      (item) => item.sessions > 0
          ? '${item.serviceName} ×${item.sessions}'
          : item.serviceName,
    )
    .join(' · ');

String _typeLabel(BuildContext context, ProviderPackageType type) =>
    switch (type) {
      ProviderPackageType.singleVisit => pd(context, 'packageTypeSingle'),
      ProviderPackageType.multiSession => pd(context, 'packageTypeMulti'),
      ProviderPackageType.creditUnits => pd(context, 'packageTypeCredits'),
      ProviderPackageType.unknown => pd(context, 'package'),
    };

String _packageMeta(BuildContext context, ProviderPackageModel package) {
  final price = pd(context, 'money', [_money(package.price)]);
  return switch (package.type) {
    ProviderPackageType.singleVisit => price,
    ProviderPackageType.multiSession => pd(context, 'packageMeta', [
      _sessionCount(package).toString(),
      _money(package.price),
    ]),
    ProviderPackageType.creditUnits => pd(context, 'packageUnitsPrice', [
      package.units.toString(),
      package.unitName ?? pd(context, 'packageUnit'),
      _money(package.price),
      _currencyLabel(context, package.currencyCode),
    ]),
    ProviderPackageType.unknown =>
      package.units > 0
          ? pd(context, 'packageUnitsPrice', [
              package.units.toString(),
              package.unitName ?? pd(context, 'packageUnit'),
              _money(package.price),
              _currencyLabel(context, package.currencyCode),
            ])
          : _sessionCount(package) > 0
          ? pd(context, 'packageMeta', [
              _sessionCount(package).toString(),
              _money(package.price),
            ])
          : price,
  };
}

String _money(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);

int _sessionCount(ProviderPackageModel package) {
  final includedSessions = package.includedServices.fold<int>(
    0,
    (total, service) => total + service.sessions,
  );
  return includedSessions > 0 ? includedSessions : package.sessions;
}

String _currencyLabel(BuildContext context, String? code) {
  final normalized = code?.trim().toUpperCase();
  final isArabic = Directionality.of(context) == TextDirection.rtl;
  if (!isArabic) return normalized?.isNotEmpty == true ? normalized! : '';
  return switch (normalized) {
    'EGP' => 'جنيه',
    'SAR' => 'ريال',
    'AED' => 'درهم',
    'KWD' => 'دينار كويتي',
    'QAR' => 'ريال قطري',
    'USD' => 'دولار',
    'EUR' => 'يورو',
    _ => normalized ?? '',
  };
}
