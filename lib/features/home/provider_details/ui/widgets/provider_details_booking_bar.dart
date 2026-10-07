import 'package:flutter/material.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';
import 'provider_details_chevron.dart';

class ProviderDetailsBookingBar extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const ProviderDetailsBookingBar({super.key, required this.state});
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 6, 6, 6),
        decoration: BoxDecoration(
          color: pdInk,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: pdInk.withValues(alpha: .18),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.selectedIds.isEmpty
                        ? pd(context, 'chooseService')
                        : pd(context, 'summary', [
                            state.selectedServices.length.toString(),
                            state.totalMinutes.toString(),
                          ]),
                    style: pdText(11, Colors.white60),
                  ),
                  Text(
                    pd(context, 'money', [state.totalPrice.toString()]),
                    style: pdText(16, Colors.white, FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: state.selectedIds.isEmpty
                  ? null
                  : () => showBookingSummary(context, state),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: pdInk,
                disabledBackgroundColor: Colors.white38,
                disabledForegroundColor: Colors.white,
                minimumSize: const Size(0, 54),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(pd(context, 'continueBooking'), style: pdText(16)),
                  const SizedBox(width: 8),
                  const ProviderDetailsChevron(),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showBookingSummary(BuildContext context, ProviderDetailsLoaded state) {
  if (state.selectedServices.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(pd(context, 'chooseService'))));
    return;
  }
  pdSheet(
    context,
    pd(context, 'bookingSummary'),
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(pd(context, state.branch.label), style: pdText(16)),
        for (final service in state.selectedServices)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(pd(context, service.label), style: pdText(16)),
            trailing: Text(
              pd(context, 'money', [service.price.toString()]),
              style: pdText(14),
            ),
          ),
        const Divider(),
        Text(
          pd(context, 'summary', [
            state.selectedServices.length.toString(),
            state.totalMinutes.toString(),
          ]),
          style: pdText(14),
        ),
        Text(
          pd(context, 'money', [state.totalPrice.toString()]),
          style: pdText(20),
        ),
        const SizedBox(height: 16),
        PdNote(pd(context, 'previewBooking')),
      ],
    ),
  );
}
