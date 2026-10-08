import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

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
              state.provider.logoUrl != null
                  ? Image.network(
                      state.provider.logoUrl!,
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
                          child: const Icon(Icons.arrow_back_rounded),
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
                                            '$name\n${state.branch?.displayAddress ?? ''}',
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
                              _providerMeta(context, state),
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
                          state.provider.isOpenNow
                              ? '• ${_openText(context, state)}'
                              : pd(context, 'closed'),
                          style: pdText(11, pdGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Contact(
                          'directions',
                          '1c61a',
                          () => openProviderMap(context, state),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => pdSheet(
                            context,
                            pd(context, 'ratedVisits', [
                              state.provider.ratingCount.toString(),
                            ]),
                            Text(
                              pd(context, 'noReviews'),
                              style: pdText(14, pdSub),
                            ),
                          ),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: pdPlate,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const PdIcon('3ed57'),
                                const SizedBox(width: 5),
                                Text(
                                  state.provider.rating == null
                                      ? pd(context, 'newRating')
                                      : state.provider.rating!.toStringAsFixed(
                                          1,
                                        ),
                                  style: pdText(),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    pd(context, 'visits', [
                                      state.provider.ratingCount.toString(),
                                    ]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: pdText(12, pdSub),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_left,
                                  size: 12,
                                  color: pdSub,
                                ),
                              ],
                            ),
                          ),
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

Future<void> openProviderMap(
  BuildContext context,
  ProviderDetailsLoaded state,
) async {
  final branch = state.branch;
  final query = branch?.latitude != null && branch?.longitude != null
      ? '${branch!.latitude},${branch.longitude}'
      : branch?.displayAddress.trim() ?? '';
  if (query.isEmpty) {
    _showLauncherError(context, 'mapUnavailable');
    return;
  }
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showLauncherError(context, 'mapUnavailable');
    }
  } catch (_) {
    if (context.mounted) _showLauncherError(context, 'mapUnavailable');
  }
}

void _showLauncherError(BuildContext context, String key) {
  AppConstant.toast(pd(context, key), false, context);
}

String _providerMeta(BuildContext context, ProviderDetailsLoaded state) {
  final parts = <String>[
    if (state.provider.category?.name.isNotEmpty == true)
      state.provider.category!.name,
    if (state.provider.distanceKm != null)
      '${state.provider.distanceKm!.toStringAsFixed(1)} ${pd(context, 'km')}',
  ];
  return parts.isEmpty ? pd(context, 'locationMeta') : parts.join(' · ');
}

String _openText(BuildContext context, ProviderDetailsLoaded state) {
  final closesAt = state.branch?.closesAt;
  if (closesAt == null) return pd(context, 'open');
  final time = closesAt.length >= 5 ? closesAt.substring(0, 5) : closesAt;
  return pd(context, 'closesAt', [time]);
}
