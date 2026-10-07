import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';
import 'provider_details_chevron.dart';

class ProviderDetailsHeader extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsHeader({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderDetailsCubit>();
    final name = state.provider.name.isEmpty
        ? pd(context, 'defaultName')
        : state.provider.name;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 250,
          child: Stack(
            fit: StackFit.expand,
            children: [
              state.provider.imageUrl != null
                  ? Image.network(
                      state.provider.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stack) => const _Cover(),
                    )
                  : const _Cover(),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x730D0D12),
                      Colors.transparent,
                      Color(0x190D0D12),
                    ],
                    stops: [0, .45, 1],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        _RoundAction(
                          label: pd(context, 'back'),
                          onTap: () => Navigator.maybePop(context),
                          child: const ProviderDetailsChevron(
                            back: true,
                            asset: 'ad532',
                          ),
                        ),
                        const Spacer(),
                        _RoundAction(
                          label: pd(context, 'share'),
                          child: const PdIcon('25005'),
                          onTap: () => pdSheet(
                            context,
                            pd(context, 'share'),
                            Column(
                              children: [
                                Text(name, style: pdText(18)),
                                const SizedBox(height: 12),
                                PdButton(
                                  pd(context, 'copy'),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            '$name\n${pd(context, state.branch.address)}',
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(pd(context, 'copied')),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RoundAction(
                          label: pd(context, 'favorite'),
                          onTap: cubit.toggleFavorite,
                          child: state.favorite
                              ? const Icon(
                                  Icons.favorite,
                                  color: pdGreen,
                                  size: 20,
                                )
                              : const PdIcon('9cd0b'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 222, bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PdCard(
              radius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: pdText(20, pdInk, FontWeight.w600),
                            ),
                            Text(
                              state.provider.branchName.isEmpty
                                  ? pd(context, 'locationMeta')
                                  : state.provider.branchName,
                              style: pdText(12, pdSub),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: pdSoft,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '• ${pd(context, 'openUntil')}',
                          style: pdText(11, pdGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => pdSheet(
                      context,
                      pd(context, 'ratedVisits', [
                        state.provider.reviewsCount.toString(),
                      ]),
                      Text(pd(context, 'noReviews'), style: pdText(14, pdSub)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: pdPlate,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PdIcon('3ed57'),
                          const SizedBox(width: 5),
                          Text(
                            state.provider.rating.toStringAsFixed(1),
                            style: pdText(),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            pd(context, 'visits', [
                              state.provider.reviewsCount.toString(),
                            ]),
                            style: pdText(12, pdSub),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.chevron_left,
                            size: 12,
                            color: pdSub,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Contact(
                          'directions',
                          '1c61a',
                          () => showProviderAddress(context, state),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Contact(
                          'call',
                          '3e677',
                          () => pdUnavailable(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover();
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/figma/provider_details/70959.png',
    fit: BoxFit.cover,
    errorBuilder: (_, error, stack) => const ColoredBox(
      color: pdSoft,
      child: Center(child: Icon(Icons.image_outlined, color: pdSub)),
    ),
  );
}

class _RoundAction extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String label;
  const _RoundAction({
    required this.child,
    required this.onTap,
    required this.label,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .94),
    shape: const CircleBorder(),
    elevation: 1,
    child: IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: child,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      padding: EdgeInsets.zero,
    ),
  );
}

class _Contact extends StatelessWidget {
  final String label, icon;
  final VoidCallback onTap;
  const _Contact(this.label, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      backgroundColor: pdPlate,
      foregroundColor: pdInk,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: const Size(0, 40),
    ),
    onPressed: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PdIcon(icon),
        const SizedBox(width: 8),
        Text(pd(context, label), style: pdText()),
      ],
    ),
  );
}

void showProviderAddress(BuildContext context, ProviderDetailsLoaded state) =>
    pdSheet(
      context,
      pd(context, 'directions'),
      Text(
        state.provider.address.isEmpty
            ? pd(context, state.branch.address)
            : state.provider.address,
        style: pdText(16),
      ),
    );
