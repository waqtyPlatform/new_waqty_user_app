import 'package:flutter/material.dart';
import 'provider_details_shared.dart';

class ProviderDetailsChevron extends StatelessWidget {
  final bool back;
  final String asset;
  const ProviderDetailsChevron({
    super.key,
    this.back = false,
    this.asset = '35f60',
  });
  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return RotatedBox(
      quarterTurns: (rtl != back) ? 1 : -1,
      child: PdIcon(asset),
    );
  }
}
