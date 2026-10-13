import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/provider_details_repo.dart';
import '../data/models/provider_booking_model.dart';
import '../data/models/provider_details_model.dart';
import 'provider_details_state.dart';

class ProviderDetailsCubit extends Cubit<ProviderDetailsState> {
  final ProviderDetailsRepo _repo;
  int _generation = 0;
  ProviderDetailsCubit(this._repo) : super(const ProviderDetailsInitial());
  Future<void> load(String uuid, {String? branchUuid}) async {
    final generation = ++_generation;
    emit(const ProviderDetailsLoading());
    final result = await _repo.show(uuid);
    if (isClosed || generation != _generation) return;
    await result.fold<Future<void>>(
      (failure) async => emit(
        failure is ProviderDetailsNotFoundFailure
            ? const ProviderDetailsNotFound()
            : ProviderDetailsError(failure.message),
      ),
      (provider) async => _emitInitialProvider(
        provider,
        requestedBranchUuid: branchUuid,
        generation: generation,
      ),
    );
  }

  Future<void> refresh() async {
    final current = state;
    if (current is! ProviderDetailsLoaded) return;
    await _loadBranchDetails(current, current.branchIndex);
  }

  void toggleService(String id) {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        !current.availableServices.any((item) => item.uuid == id)) {
      return;
    }
    final selected = current.selectedIds.contains(id) ? <String>{} : {id};
    emit(current.copyWith(selectedIds: selected));
  }

  void selectSpecialist(String? id) {
    final current = state;
    if (current is! ProviderDetailsLoaded) return;
    if (id != null &&
        !current.availableEmployees.any((item) => item.uuid == id)) {
      return;
    }
    emit(current.copyWith(specialistId: id, clearSpecialist: id == null));
  }

  Future<void> selectBranch(int index) async {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        index < 0 ||
        index >= current.provider.branches.length ||
        index == current.branchIndex) {
      return;
    }
    await _loadBranchDetails(current, index);
  }

  void toggleFavorite() {
    final current = state;
    if (current is ProviderDetailsLoaded) {
      emit(current.copyWith(favorite: !current.favorite));
    }
  }

  Future<void> _emitInitialProvider(
    ProviderDetailsModel provider, {
    required String? requestedBranchUuid,
    required int generation,
  }) async {
    if (provider.branches.isEmpty) {
      emit(ProviderDetailsLoaded(provider));
      return;
    }
    final selectedUuid = requestedBranchUuid ?? provider.branchUuid;
    final branchIndex = selectedUuid == null
        ? 0
        : provider.branches.indexWhere((branch) => branch.uuid == selectedUuid);
    final resolvedIndex = branchIndex < 0 ? 0 : branchIndex;
    final resolvedUuid = provider.branches[resolvedIndex].uuid;

    if (provider.branchUuid == resolvedUuid) {
      emit(ProviderDetailsLoaded(provider, branchIndex: resolvedIndex));
      return;
    }

    final filtered = await _repo.show(provider.uuid, branchUuid: resolvedUuid);
    if (isClosed || generation != _generation) return;
    filtered.fold(
      (failure) => emit(
        failure is ProviderDetailsNotFoundFailure
            ? const ProviderDetailsNotFound()
            : ProviderDetailsError(failure.message),
      ),
      (details) => emit(
        ProviderDetailsLoaded(
          details.copyWith(
            branchUuid: resolvedUuid,
            branches: provider.branches,
          ),
          branchIndex: resolvedIndex,
        ),
      ),
    );
  }

  Future<void> _loadBranchDetails(
    ProviderDetailsLoaded current,
    int branchIndex,
  ) async {
    final branches = current.provider.branches;
    final branchUuid = branches[branchIndex].uuid;
    emit(current.copyWith(branchLoading: true));
    final result = await _repo.show(
      current.provider.uuid,
      branchUuid: branchUuid,
    );
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (_) => emit(current.copyWith(branchLoading: false)),
      (provider) => emit(
        current.copyWith(
          provider: provider.copyWith(
            branchUuid: branchUuid,
            branches: branches,
          ),
          branchIndex: branchIndex,
          selectedIds: const {},
          clearSpecialist: true,
          bookingEmployees: const [],
          branchLoading: false,
        ),
      ),
    );
  }

  Future<void> startServiceBooking() async {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        current.selectedIds.length != 1 ||
        current.branch == null) {
      return;
    }
    emit(
      current.copyWith(
        bookingKind: ProviderBookingKind.service,
        bookingStep: ProviderBookingStep.employee,
        bookingLoading: true,
        bookingError: null,
        bookingEmployees: const [],
        bookingDates: const [],
        bookingSlots: const [],
        bookingDate: null,
        slotToken: null,
        packageId: null,
        entitlementId: null,
        bookingCompleted: false,
        waitlistJoined: false,
      ),
    );
    final result = await _repo.bookingEmployees(
      current.provider.uuid,
      current.branch!.uuid,
      current.selectedIds.single,
    );
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingError: failure.message,
        ),
      ),
      (data) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingEmployees: data.employees,
          allowAnyEmployee: data.allowAnyEmployee,
        ),
      ),
    );
  }

  Future<void> chooseEmployee(String? employeeUuid) async {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        current.branch == null ||
        current.selectedIds.isEmpty) {
      return;
    }
    emit(
      current.copyWith(
        specialistId: employeeUuid,
        clearSpecialist: employeeUuid == null,
        bookingStep: ProviderBookingStep.date,
        bookingLoading: true,
        bookingError: null,
        bookingDates: const [],
      ),
    );
    final result = await _repo.bookingDates(
      providerUuid: current.provider.uuid,
      branchUuid: current.branch!.uuid,
      serviceUuid: current.selectedIds.single,
      employeeUuid: employeeUuid,
      timezone: _timezone(current),
    );
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingError: failure.message,
        ),
      ),
      (dates) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingDates: dates,
        ),
      ),
    );
  }

  Future<void> startPackageBooking(String packageUuid) async {
    final current = state;
    if (current is! ProviderDetailsLoaded || current.branch == null) return;
    emit(
      current.copyWith(
        bookingKind: ProviderBookingKind.package,
        packageId: packageUuid,
        entitlementId: null,
        selectedIds: const {},
        bookingStep: ProviderBookingStep.date,
        bookingLoading: true,
        bookingError: null,
        bookingDates: const [],
        bookingSlots: const [],
        bookingDate: null,
        slotToken: null,
        bookingCompleted: false,
        waitlistJoined: false,
      ),
    );
    final result = await _repo.packageDates(
      providerUuid: current.provider.uuid,
      branchUuid: current.branch!.uuid,
      packageUuid: packageUuid,
      timezone: _timezone(current),
    );
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingError: failure.message,
        ),
      ),
      (dates) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingDates: dates,
        ),
      ),
    );
  }

  Future<void> startOwnedPackageBooking({
    required String entitlementUuid,
    required String packageUuid,
  }) async {
    await _startDirectBooking(
      kind: ProviderBookingKind.ownedPackage,
      itemUuid: packageUuid,
      entitlementUuid: entitlementUuid,
      loadDates: (current) => _repo.packageDates(
        providerUuid: current.provider.uuid,
        branchUuid: current.branch!.uuid,
        packageUuid: packageUuid,
        timezone: _timezone(current),
      ),
    );
  }

  Future<void> startFollowUpBooking({
    required String entitlementUuid,
    required String serviceUuid,
  }) async {
    await _startDirectBooking(
      kind: ProviderBookingKind.followUp,
      itemUuid: serviceUuid,
      entitlementUuid: entitlementUuid,
      loadDates: (current) => _repo.bookingDates(
        providerUuid: current.provider.uuid,
        branchUuid: current.branch!.uuid,
        serviceUuid: serviceUuid,
        timezone: _timezone(current),
      ),
    );
  }

  Future<void> _startDirectBooking({
    required ProviderBookingKind kind,
    required String itemUuid,
    required String entitlementUuid,
    required Future<dynamic> Function(ProviderDetailsLoaded current) loadDates,
  }) async {
    final current = state;
    if (current is! ProviderDetailsLoaded || current.branch == null) return;
    emit(
      current.copyWith(
        bookingKind: kind,
        packageId: kind == ProviderBookingKind.ownedPackage ? itemUuid : null,
        entitlementId: entitlementUuid,
        selectedIds: kind == ProviderBookingKind.followUp
            ? {itemUuid}
            : const {},
        clearSpecialist: true,
        bookingStep: ProviderBookingStep.date,
        bookingLoading: true,
        bookingError: null,
        bookingDates: const [],
        bookingSlots: const [],
        bookingDate: null,
        slotToken: null,
        bookingCompleted: false,
        waitlistJoined: false,
      ),
    );
    final result = await loadDates(current);
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingError: failure.message,
        ),
      ),
      (dates) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingDates: dates,
        ),
      ),
    );
  }

  Future<void> chooseDate(DateTime date) async {
    final current = state;
    if (current is! ProviderDetailsLoaded || current.branch == null) return;
    emit(
      current.copyWith(
        bookingDate: date,
        bookingStep: ProviderBookingStep.slot,
        bookingLoading: true,
        bookingError: null,
        bookingSlots: const [],
        slotToken: null,
        waitlistEnabled: false,
      ),
    );
    final result =
        current.bookingKind == ProviderBookingKind.service ||
            current.bookingKind == ProviderBookingKind.followUp
        ? await _repo.bookingSlots(
            providerUuid: current.provider.uuid,
            branchUuid: current.branch!.uuid,
            serviceUuid: current.selectedIds.single,
            employeeUuid: current.specialistId,
            date: date,
            timezone: _timezone(current),
          )
        : await _repo.packageSlots(
            providerUuid: current.provider.uuid,
            branchUuid: current.branch!.uuid,
            packageUuid: current.packageId!,
            date: date,
            timezone: _timezone(current),
          );
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingError: failure.message,
        ),
      ),
      (slots) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingLoading: false,
          bookingSlots: slots.slots,
          waitlistEnabled: slots.waitlistEnabled,
        ),
      ),
    );
  }

  void chooseSlot(String token) {
    final current = state;
    if (current is ProviderDetailsLoaded &&
        current.bookingSlots.any((slot) => slot.slotToken == token)) {
      emit(current.copyWith(slotToken: token));
    }
  }

  Future<void> refreshBookingStep() async {
    final current = state;
    if (current is! ProviderDetailsLoaded || current.bookingLoading) return;
    switch (current.bookingStep) {
      case ProviderBookingStep.employee:
        await startServiceBooking();
      case ProviderBookingStep.date:
        switch (current.bookingKind) {
          case ProviderBookingKind.service:
            await chooseEmployee(current.specialistId);
          case ProviderBookingKind.package:
            await startPackageBooking(current.packageId!);
          case ProviderBookingKind.ownedPackage:
            await startOwnedPackageBooking(
              entitlementUuid: current.entitlementId!,
              packageUuid: current.packageId!,
            );
          case ProviderBookingKind.followUp:
            await startFollowUpBooking(
              entitlementUuid: current.entitlementId!,
              serviceUuid: current.selectedIds.single,
            );
        }
      case ProviderBookingStep.slot:
        final date = current.bookingDate;
        if (date != null) await chooseDate(date);
      case ProviderBookingStep.complete:
        return;
    }
  }

  bool backBookingStep() {
    final current = state;
    if (current is! ProviderDetailsLoaded) return false;
    if (current.bookingStep == ProviderBookingStep.slot) {
      emit(
        current.copyWith(
          bookingStep: ProviderBookingStep.date,
          bookingLoading: false,
          bookingError: null,
          bookingSlots: const [],
          slotToken: null,
          waitlistEnabled: false,
        ),
      );
      return true;
    }
    if (current.bookingStep == ProviderBookingStep.date &&
        current.bookingKind == ProviderBookingKind.service) {
      emit(
        current.copyWith(
          bookingStep: ProviderBookingStep.employee,
          clearSpecialist: true,
          bookingLoading: false,
          bookingError: null,
          bookingDate: null,
          bookingSlots: const [],
          slotToken: null,
          waitlistEnabled: false,
        ),
      );
      return true;
    }
    return false;
  }

  Future<void> confirmBooking() async {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        current.branch == null ||
        current.slotToken == null ||
        current.bookingDate == null) {
      return;
    }
    emit(current.copyWith(bookingSubmitting: true, bookingError: null));
    final body = <String, dynamic>{
      'branch_uuid': current.branch!.uuid,
      if (current.bookingKind == ProviderBookingKind.service)
        'service_uuid': current.selectedIds.single,
      if (current.bookingKind == ProviderBookingKind.service)
        'employee_uuid': current.specialistId,
      if (current.bookingKind == ProviderBookingKind.package)
        'package_uuid': current.packageId,
      if (current.bookingKind == ProviderBookingKind.ownedPackage)
        'entitlement_uuid': current.entitlementId,
      if (current.bookingKind == ProviderBookingKind.followUp)
        'follow_up_uuid': current.entitlementId,
      'slot_token': current.slotToken,
      'booking_date': _date(current.bookingDate!),
    };
    final result = await _repo.createBooking(body);
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingSubmitting: false,
          bookingError: failure.message,
        ),
      ),
      (_) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingSubmitting: false,
          bookingCompleted: true,
          bookingStep: ProviderBookingStep.complete,
        ),
      ),
    );
  }

  Future<void> joinWaitlist(String preferredTime) async {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        current.branch == null ||
        current.bookingDate == null) {
      return;
    }
    emit(current.copyWith(bookingSubmitting: true, bookingError: null));
    final result = await _repo.joinWaitlist({
      'branch_uuid': current.branch!.uuid,
      if (current.bookingKind == ProviderBookingKind.service)
        'service_uuid': current.selectedIds.single,
      if (current.bookingKind == ProviderBookingKind.service)
        'employee_uuid': current.specialistId,
      if (current.bookingKind == ProviderBookingKind.package)
        'package_uuid': current.packageId,
      if (current.bookingKind == ProviderBookingKind.ownedPackage)
        'entitlement_uuid': current.entitlementId,
      if (current.bookingKind == ProviderBookingKind.followUp)
        'follow_up_uuid': current.entitlementId,
      'preferred_date': _date(current.bookingDate!),
      'preferred_time': preferredTime,
    });
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingSubmitting: false,
          bookingError: failure.message,
        ),
      ),
      (_) => emit(
        (state as ProviderDetailsLoaded).copyWith(
          bookingSubmitting: false,
          waitlistJoined: true,
          bookingStep: ProviderBookingStep.complete,
        ),
      ),
    );
  }

  String _timezone(ProviderDetailsLoaded state) =>
      state.provider.currencyCode == 'SAR' ? 'Asia/Riyadh' : 'Africa/Cairo';
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
