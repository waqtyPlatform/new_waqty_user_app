import 'package:flutter/material.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

class ProviderDetailsBookingBar extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsBookingBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: FilledButton(
        onPressed: state.branch == null
            ? null
            : () => Navigator.pushNamed(
                context,
                Routes.providerBookingScreen,
                arguments: {
                  'provider_uuid': state.provider.uuid,
                  'branch_uuid': state.branch!.uuid,
                  'provider_name': state.provider.name,
                },
              ),
        style: FilledButton.styleFrom(
          backgroundColor: pdInk,
          foregroundColor: Colors.white,
          disabledBackgroundColor: pdSub,
          minimumSize: const Size.fromHeight(58),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              pd(context, 'bookNow'),
              style: pdText(16, Colors.white, FontWeight.w600),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    ),
  );
}
