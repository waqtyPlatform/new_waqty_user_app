import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/provider_catalog.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';
import 'provider_details_chevron.dart';

class ProviderDetailsPackages extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsPackages({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderDetailsCubit>();
    if (state.branch.packages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: PdCard(
          radius: 24,
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: pdPlate,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(child: PdIcon('ea57a')),
              ),
              const SizedBox(height: 18),
              Text(
                pd(context, 'emptyPackages'),
                textAlign: TextAlign.center,
                style: pdText(20, pdInk, FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                pd(context, 'emptyPackagesHint'),
                textAlign: TextAlign.center,
                style: pdText(12, pdSub),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: cubit.toggleFavorite,
                icon: Icon(
                  state.favorite ? Icons.bookmark : Icons.bookmark_border,
                  size: 16,
                  color: pdGreen,
                ),
                label: Text(
                  pd(context, 'notifySaved'),
                  style: pdText(12, pdGreen),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: PdButton(
                  pd(context, 'viewServices'),
                  onPressed: () => cubit.selectTab(ProviderDetailsTab.services),
                ),
              ),
              TextButton(
                onPressed: () {
                  final available = state.catalog.branches.indexWhere(
                    (branch) => branch.packages.isNotEmpty,
                  );
                  if (available >= 0) {
                    cubit.selectBranch(available);
                  } else {
                    pdUnavailable(context);
                  }
                },
                child: Text(
                  pd(context, 'otherPackages'),
                  style: pdText(12, pdSub),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PdHeading(pd(context, 'packagesTitle'), pd(context, 'packagesHint')),
        for (final package in state.branch.packages)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProviderPackageCard(package: package),
          ),
      ],
    );
  }
}

class ProviderPackageCard extends StatelessWidget {
  final ProviderPackage package;
  const ProviderPackageCard({super.key, required this.package});
  @override
  Widget build(BuildContext context) => PdCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: package.oldPrice == null
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFFFEEFF2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                pd(context, package.oldPrice == null ? 'package' : 'offer'),
                style: pdText(
                  10,
                  package.oldPrice == null ? pdSub : const Color(0xFFDF1C41),
                ),
              ),
            ),
            const Spacer(),
            Text(
              package.sessions == 1
                  ? pd(context, 'singleVisit')
                  : pd(context, 'sessions', [package.sessions.toString()]),
              style: pdText(10, pdSub),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          pd(context, package.label),
          style: pdText(16, pdInk, FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 6,
          children: [
            Text(
              pd(context, 'money', [package.price.toString()]),
              style: pdText(18, pdInk, FontWeight.w600),
            ),
            if (package.oldPrice != null)
              Text(
                pd(context, 'money', [package.oldPrice.toString()]),
                style: pdText(
                  11,
                  pdSub,
                ).copyWith(decoration: TextDecoration.lineThrough),
              ),
            Text(
              pd(context, package.validity),
              style: pdText(11, const Color(0xFF956321)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => pdSheet(
            context,
            pd(context, package.label),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  pd(context, 'sessions', [package.sessions.toString()]),
                  style: pdText(16),
                ),
                Text(pd(context, package.validity), style: pdText(14, pdSub)),
                Text(
                  pd(context, 'money', [package.price.toString()]),
                  style: pdText(20),
                ),
                const SizedBox(height: 16),
                PdNote(pd(context, 'previewBooking')),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(pd(context, 'packageDetails'), style: pdText(12, pdGreen)),
                const SizedBox(width: 6),
                const ProviderDetailsChevron(asset: 'c1379'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
