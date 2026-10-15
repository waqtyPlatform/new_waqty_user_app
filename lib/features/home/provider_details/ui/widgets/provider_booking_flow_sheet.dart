import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/features/home/provider_booking/data/models/booking_cart_model.dart';
import 'package:waqty_user_application/features/home/provider_booking/logic/booking_cart_cubit.dart';
import 'package:waqty_user_application/features/home/provider_booking/logic/booking_cart_state.dart';
import '../../data/models/provider_booking_model.dart';
import '../../data/models/provider_details_model.dart';
import '../../logic/provider_details_cubit.dart';
import '../../logic/provider_details_state.dart';
import 'provider_details_shared.dart';

Future<void> showProviderBookingFlow(BuildContext context) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ProviderDetailsCubit>()),
            BlocProvider.value(value: context.read<BookingCartCubit>()),
          ],
          child: const _ProviderBookingFlowScreen(),
        ),
      ),
    );

class _ProviderBookingFlowScreen extends StatelessWidget {
  const _ProviderBookingFlowScreen();

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<BookingCartCubit, BookingCartState>(
    listenWhen: (previous, current) => previous.actionId != current.actionId,
    listener: (context, state) {
      if (state.action == BookingCartAction.itemAdded) {
        AppConstant.toast(
          context.tr('providerBooking.addedToCart'),
          true,
          context,
        );
        Navigator.pop(context);
      } else if (state.action == BookingCartAction.failed) {
        AppConstant.toast(
          context.tr(_cartErrorKey(state.errorCode)),
          false,
          context,
        );
      }
    },
    child: BlocConsumer<ProviderDetailsCubit, ProviderDetailsState>(
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
        if (state is! ProviderDetailsLoaded) {
          return const Scaffold(
            backgroundColor: AppColors.pageColor,
            appBar: _BookingFlowAppBar(),
            body: SafeArea(top: false, child: _BookingFlowShimmer()),
          );
        }
        final handlesBack =
            state.bookingStep == ProviderBookingStep.slot ||
            (state.bookingStep == ProviderBookingStep.date &&
                state.bookingKind == ProviderBookingKind.service);
        return PopScope(
          canPop: !handlesBack,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              context.read<ProviderDetailsCubit>().backBookingStep();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.pageColor,
            appBar: const _BookingFlowAppBar(),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  _StepHeader(state: state),
                  Expanded(
                    child: state.bookingLoading
                        ? const _BookingFlowShimmer()
                        : state.bookingError != null
                        ? _ErrorState(state: state)
                        : RefreshIndicator(
                            onRefresh: context
                                .read<ProviderDetailsCubit>()
                                .refreshBookingStep,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                              child: _content(context, state),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _content(BuildContext context, ProviderDetailsLoaded state) {
    final cubit = context.read<ProviderDetailsCubit>();
    if (state.bookingStep == ProviderBookingStep.employee) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.allowAnyEmployee)
            _EmployeeTile(
              title: pd(context, 'anySpecialist'),
              subtitle: pd(context, 'anyHint'),
              icon: Icons.groups_2_outlined,
              onTap: () => cubit.chooseEmployee(null),
            ),
          for (final employee in state.bookingEmployees)
            _EmployeeTile(
              title: employee.name,
              subtitle: employee.jobTitle,
              employee: employee,
              onTap: () => cubit.chooseEmployee(employee.uuid),
            ),
        ],
      );
    }
    if (state.bookingStep == ProviderBookingStep.date) {
      final dates = state.bookingDates
          .where((date) => date.available && date.slotsCount > 0)
          .toList(growable: false);
      if (dates.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PdNote(pd(context, 'noDates')),
            if (state.bookingRequiresPurchase) ...[
              const SizedBox(height: 16),
              _BuyPackageOnlyButton(state: state),
            ],
          ],
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dates.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth >= 500 ? 3 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.05,
          ),
          itemBuilder: (_, index) {
            final date = dates[index];
            return _DateTile(
              date: date,
              selected: state.bookingDate == date.date,
              onTap: () => cubit.chooseDate(date.date),
            );
          },
        ),
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
        _SelectedDateBanner(date: state.bookingDate!),
        const SizedBox(height: 20),
        Text(
          pd(context, 'availableTimes'),
          style: pdText(16, pdInk, FontWeight.w600),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.bookingSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.15,
          ),
          itemBuilder: (_, index) {
            final slot = state.bookingSlots[index];
            final selected = state.slotToken == slot.slotToken;
            return InkWell(
              onTap: () => cubit.chooseSlot(slot.slotToken),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? pdGreen : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? pdGreen : pdInk.withValues(alpha: .10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: Text(
                        _time(context, slot.startsAt),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: pdText(
                          13,
                          selected ? Colors.white : pdInk,
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        if (state.slotToken != null) ...[
          _SelectedSlotSummary(
            time: _time(
              context,
              state.bookingSlots
                  .firstWhere((slot) => slot.slotToken == state.slotToken)
                  .startsAt,
            ),
          ),
          const SizedBox(height: 12),
        ],
        BlocBuilder<BookingCartCubit, BookingCartState>(
          builder: (context, cartState) => PdButton(
            context.tr(
              cartState.mutating
                  ? 'providerBooking.addingToCart'
                  : 'providerBooking.addToCart',
            ),
            onPressed: state.slotToken == null || cartState.mutating
                ? null
                : () => _addToCart(context, state),
          ),
        ),
      ],
    );
  }

  void _addToCart(BuildContext context, ProviderDetailsLoaded state) {
    final branch = state.branch;
    final slotToken = state.slotToken;
    if (branch == null || slotToken == null) return;
    context.read<BookingCartCubit>().addItem(
      BookingCartAddRequest(
        providerUuid: state.provider.uuid,
        branchUuid: branch.uuid,
        slotToken: slotToken,
        idempotencyKey: newIdempotencyKey(),
        itemType: _cartItemType(state),
        serviceUuid:
            state.bookingKind == ProviderBookingKind.service ||
                state.bookingKind == ProviderBookingKind.followUp ||
                state.bookingKind == ProviderBookingKind.ownedPackage
            ? state.selectedIds.firstOrNull
            : null,
        packageUuid:
            state.bookingKind == ProviderBookingKind.package ||
                state.bookingKind == ProviderBookingKind.ownedPackage
            ? state.packageId
            : null,
        entitlementUuid: state.bookingKind == ProviderBookingKind.ownedPackage
            ? state.entitlementId
            : null,
        followUpUuid: state.bookingKind == ProviderBookingKind.followUp
            ? state.entitlementId
            : null,
        employeeUuid: state.bookingKind == ProviderBookingKind.service
            ? state.specialistId
            : null,
      ),
    );
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

  String _time(BuildContext context, String value) {
    final locale = Localizations.localeOf(context).languageCode;
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return DateFormat.jm(locale).format(parsed.toLocal());
    }
    final parts = value.split(':');
    if (parts.length < 2) return value;
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateFormat.jm(locale).format(DateTime(2000, 1, 1, hour, minute));
  }
}

BookingCartItemType _cartItemType(ProviderDetailsLoaded state) =>
    switch (state.bookingKind) {
      ProviderBookingKind.service => BookingCartItemType.service,
      ProviderBookingKind.package =>
        state.bookingRequiresPurchase
            ? BookingCartItemType.packagePurchase
            : BookingCartItemType.package,
      ProviderBookingKind.ownedPackage => BookingCartItemType.ownedPackage,
      ProviderBookingKind.followUp => BookingCartItemType.followUp,
    };

String _cartErrorKey(String? code) => switch (code) {
  'SLOT_UNAVAILABLE' => 'providerBooking.slotUnavailable',
  'CART_ITEM_EXPIRED' => 'providerBooking.cartItemExpired',
  'CART_CONTEXT_MISMATCH' => 'providerBooking.cartContextChanged',
  _ => 'providerBooking.cartError',
};

class _SelectedDateBanner extends StatelessWidget {
  final DateTime date;
  const _SelectedDateBanner({required this.date});

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pdSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month_outlined, color: pdGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat('EEEE، d MMMM', language).format(date),
              style: pdText(15, pdInk, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyPackageOnlyButton extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const _BuyPackageOnlyButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final branch = state.branch;
    final packageUuid = state.packageId;
    return BlocBuilder<BookingCartCubit, BookingCartState>(
      builder: (context, cartState) => PdButton(
        context.tr('providerBooking.buyPackageOnly'),
        dark: false,
        onPressed: branch == null || packageUuid == null || cartState.mutating
            ? null
            : () => context.read<BookingCartCubit>().addItem(
                BookingCartAddRequest(
                  providerUuid: state.provider.uuid,
                  branchUuid: branch.uuid,
                  packageUuid: packageUuid,
                  itemType: BookingCartItemType.packagePurchaseOnly,
                  idempotencyKey: newIdempotencyKey(),
                ),
              ),
      ),
    );
  }
}

class _SelectedSlotSummary extends StatelessWidget {
  final String time;
  const _SelectedSlotSummary({required this.time});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: pdGreen.withValues(alpha: .28)),
    ),
    child: Row(
      children: [
        const Icon(Icons.schedule_rounded, color: pdGreen, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            pd(context, 'selectedAppointment'),
            style: pdText(13, pdSub, FontWeight.w500),
          ),
        ),
        Text(time, style: pdText(15, pdInk, FontWeight.w700)),
      ],
    ),
  );
}

class _BookingFlowAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _BookingFlowAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: AppColors.pageColor,
    surfaceTintColor: Colors.transparent,
    automaticallyImplyLeading: false,
    centerTitle: true,
    title: Text(pd(context, 'booking')),
    leadingWidth: 64,
    leading: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: pdInk.withValues(alpha: .10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: IconButton(
            onPressed: () {
              if (!context.read<ProviderDetailsCubit>().backBookingStep()) {
                Navigator.maybePop(context);
              }
            },
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
      ),
    ),
  );
}

class _BookingFlowShimmer extends StatelessWidget {
  const _BookingFlowShimmer();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFE7E8EA),
    highlightColor: const Color(0xFFF7F7F8),
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            width: 130,
            height: 22,
            decoration: _shimmerDecoration(8),
          ),
        ),
        const SizedBox(height: 12),
        Container(height: 4, decoration: _shimmerDecoration(4)),
        const SizedBox(height: 20),
        for (var index = 0; index < 4; index++) ...[
          Container(
            height: 76,
            padding: const EdgeInsets.all(13),
            decoration: _shimmerDecoration(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 14,
                        decoration: _shimmerDecoration(6),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        width: 90,
                        height: 10,
                        decoration: _shimmerDecoration(5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    ),
  );

  static BoxDecoration _shimmerDecoration(double radius) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
  );
}

class _StepHeader extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const _StepHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final step = switch (state.bookingStep) {
      ProviderBookingStep.employee => 1,
      ProviderBookingStep.date =>
        state.bookingKind == ProviderBookingKind.service ? 2 : 1,
      ProviderBookingStep.slot =>
        state.bookingKind == ProviderBookingKind.service ? 3 : 2,
      ProviderBookingStep.complete => 3,
    };
    final total = state.bookingKind == ProviderBookingKind.service ? 3 : 2;
    final title = switch (state.bookingStep) {
      ProviderBookingStep.employee => pd(context, 'chooseEmployee'),
      ProviderBookingStep.date => pd(context, 'chooseDate'),
      ProviderBookingStep.slot => pd(context, 'chooseSlot'),
      ProviderBookingStep.complete => pd(context, 'done'),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: pdText(22, pdInk, FontWeight.w600)),
              ),
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  '$step / $total',
                  style: pdText(13, pdGreen, FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: step / total,
              backgroundColor: pdInk.withValues(alpha: .08),
              color: pdGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final ProviderDetailsLoaded state;
  const _ErrorState({required this.state});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PdNote(pd(context, 'bookingError')),
          const SizedBox(height: 12),
          PdButton(pd(context, 'retry'), onPressed: () => _retry(context)),
        ],
      ),
    ),
  );

  void _retry(BuildContext context) {
    final cubit = context.read<ProviderDetailsCubit>();
    if (state.bookingStep == ProviderBookingStep.employee) {
      cubit.startServiceBooking();
    } else if (state.bookingStep == ProviderBookingStep.date) {
      switch (state.bookingKind) {
        case ProviderBookingKind.package:
          cubit.startPackageBooking(state.packageId!);
        case ProviderBookingKind.ownedPackage:
          cubit.startOwnedPackageBooking(
            entitlementUuid: state.entitlementId!,
            packageUuid: state.packageId!,
            serviceUuid: state.selectedIds.single,
          );
        case ProviderBookingKind.followUp:
          cubit.startFollowUpBooking(
            entitlementUuid: state.entitlementId!,
            serviceUuid: state.selectedIds.single,
          );
        case ProviderBookingKind.service:
          cubit.chooseEmployee(state.specialistId);
      }
    } else if (state.bookingDate != null) {
      cubit.chooseDate(state.bookingDate!);
    }
  }
}

class _EmployeeTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ProviderEmployeeModel? employee;
  final IconData? icon;
  final VoidCallback onTap;
  const _EmployeeTile({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.employee,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: pdInk.withValues(alpha: .08)),
          ),
          child: Row(
            children: [
              _Avatar(employee: employee, icon: icon, title: title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: pdText(16, pdInk, FontWeight.w600)),
                    if (subtitle?.trim().isNotEmpty == true)
                      Text(subtitle!, style: pdText(12, pdSub)),
                  ],
                ),
              ),
              const Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Icon(Icons.chevron_left_rounded, color: pdSub),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Avatar extends StatelessWidget {
  final ProviderEmployeeModel? employee;
  final IconData? icon;
  final String title;
  const _Avatar({
    required this.employee,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final photo = employee?.photoUrl;
    return CircleAvatar(
      radius: 25,
      backgroundColor: pdSoft,
      backgroundImage: photo == null ? null : NetworkImage(photo),
      child: photo != null
          ? null
          : icon != null
          ? Icon(icon, color: pdGreen)
          : Text(
              title.trim().isEmpty ? '' : title.trim()[0],
              style: pdText(17, pdGreen, FontWeight.w600),
            ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final ProviderBookingDateModel date;
  final bool selected;
  final VoidCallback onTap;
  const _DateTile({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? pdSoft : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? pdGreen : pdInk.withValues(alpha: .10),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? pdGreen : pdSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  DateFormat('d').format(date.date),
                  style: pdText(
                    21,
                    selected ? Colors.white : pdGreen,
                    FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE', language).format(date.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pdText(13, pdInk, FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM', language).format(date.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pdText(11, pdGreen, FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
