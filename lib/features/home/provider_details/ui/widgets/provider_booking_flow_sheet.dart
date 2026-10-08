import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import '../../data/models/provider_booking_model.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

Future<void> showProviderBookingFlow(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => BlocProvider.value(
        value: context.read<ProviderDetailsCubit>(),
        child: const _ProviderBookingFlowSheet(),
      ),
    );

class _ProviderBookingFlowSheet extends StatelessWidget {
  const _ProviderBookingFlowSheet();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ProviderDetailsCubit, ProviderDetailsState>(
        listenWhen: (previous, current) {
          if (previous is! ProviderDetailsLoaded ||
              current is! ProviderDetailsLoaded) {
            return false;
          }
          return previous.bookingCompleted != current.bookingCompleted ||
              previous.waitlistJoined != current.waitlistJoined;
        },
        listener: (context, state) {
          if (state is! ProviderDetailsLoaded) return;
          if (state.bookingCompleted || state.waitlistJoined) {
            AppConstant.toast(
              pd(
                context,
                state.waitlistJoined ? 'waitlistSuccess' : 'bookingSuccess',
              ),
              true,
              context,
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is! ProviderDetailsLoaded) return const SizedBox.shrink();
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .82,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _title(context, state),
                      style: pdText(20, pdInk, FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    if (state.bookingLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (state.bookingError != null) ...[
                      PdNote(pd(context, 'bookingError')),
                      const SizedBox(height: 12),
                      PdButton(
                        pd(context, 'retry'),
                        onPressed: () => _retry(context, state),
                      ),
                    ] else
                      _content(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      );

  String _title(BuildContext context, ProviderDetailsLoaded state) =>
      switch (state.bookingStep) {
        ProviderBookingStep.employee => pd(context, 'chooseEmployee'),
        ProviderBookingStep.date => pd(context, 'chooseDate'),
        ProviderBookingStep.slot => pd(context, 'chooseSlot'),
        ProviderBookingStep.complete => pd(context, 'done'),
      };

  Widget _content(BuildContext context, ProviderDetailsLoaded state) {
    final cubit = context.read<ProviderDetailsCubit>();
    if (state.bookingStep == ProviderBookingStep.employee) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.allowAnyEmployee)
            _ChoiceTile(
              title: pd(context, 'anySpecialist'),
              subtitle: pd(context, 'anyHint'),
              onTap: () => cubit.chooseEmployee(null),
            ),
          for (final employee in state.bookingEmployees)
            _ChoiceTile(
              title: employee.name,
              subtitle: employee.jobTitle,
              onTap: () => cubit.chooseEmployee(employee.uuid),
            ),
        ],
      );
    }
    if (state.bookingStep == ProviderBookingStep.date) {
      if (state.bookingDates.isEmpty) return PdNote(pd(context, 'noDates'));
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final date in state.bookingDates)
            ChoiceChip(
              label: Text(
                DateFormat(
                  'EEE d/M',
                  Localizations.localeOf(context).languageCode,
                ).format(date.date),
              ),
              selected: state.bookingDate == date.date,
              onSelected: (_) => cubit.chooseDate(date.date),
            ),
        ],
      );
    }
    if (state.bookingSlots.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PdNote(pd(context, 'noSlots')),
          if (state.waitlistEnabled) ...[
            const SizedBox(height: 16),
            PdButton(
              pd(context, state.bookingSubmitting ? 'sending' : 'joinWaitlist'),
              onPressed: state.bookingSubmitting
                  ? null
                  : () => _joinWaitlist(context),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final slot in state.bookingSlots)
              ChoiceChip(
                label: Text(_time(slot.startsAt)),
                selected: state.slotToken == slot.slotToken,
                onSelected: (_) => cubit.chooseSlot(slot.slotToken),
              ),
          ],
        ),
        const SizedBox(height: 18),
        PdButton(
          pd(context, state.bookingSubmitting ? 'sending' : 'confirmBooking'),
          onPressed: state.slotToken == null || state.bookingSubmitting
              ? null
              : cubit.confirmBooking,
        ),
      ],
    );
  }

  void _retry(BuildContext context, ProviderDetailsLoaded state) {
    final cubit = context.read<ProviderDetailsCubit>();
    if (state.bookingStep == ProviderBookingStep.employee) {
      cubit.startServiceBooking();
    } else if (state.bookingStep == ProviderBookingStep.date) {
      if (state.bookingKind == ProviderBookingKind.package) {
        cubit.startPackageBooking(state.packageId!);
      } else {
        cubit.chooseEmployee(state.specialistId);
      }
    } else if (state.bookingDate != null) {
      cubit.chooseDate(state.bookingDate!);
    }
  }

  Future<void> _joinWaitlist(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !context.mounted) return;
    await context.read<ProviderDetailsCubit>().joinWaitlist(
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    );
  }

  String _time(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateFormat('h:mm a').format(parsed.toLocal());
    final parts = value.split(':');
    if (parts.length < 2) return value;
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateFormat('h:mm a').format(DateTime(2000, 1, 1, hour, minute));
  }
}

class _ChoiceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _ChoiceTile({required this.title, this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: PdCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: pdText(16, pdInk, FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle!, style: pdText(12, pdSub)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left),
          ],
        ),
      ),
    ),
  );
}
