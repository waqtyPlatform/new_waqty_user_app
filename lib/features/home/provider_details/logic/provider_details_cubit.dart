import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/provider_details_repo.dart';
import '../data/models/provider_booking_model.dart';
import 'provider_details_state.dart';

class ProviderDetailsCubit extends Cubit<ProviderDetailsState> {
  final ProviderDetailsRepo _repo;
  int _generation = 0;
  ProviderDetailsCubit(this._repo) : super(const ProviderDetailsInitial());
  Future<void> load(String uuid) async {
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
      (provider) async {
        final loaded = ProviderDetailsLoaded(provider);
        emit(loaded);
        await _loadBranchServices(loaded);
      },
    );
  }

  void selectTab(ProviderDetailsTab tab) {
    final current = state;
    if (current is ProviderDetailsLoaded) emit(current.copyWith(tab: tab));
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
        !current.provider.employees.any((item) => item.uuid == id)) {
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
    final next = current.copyWith(
      branchIndex: index,
      selectedIds: {},
      clearSpecialist: true,
      bookingServices: const [],
    );
    emit(next);
    await _loadBranchServices(next);
  }

  void toggleFavorite() {
    final current = state;
    if (current is ProviderDetailsLoaded) {
      emit(current.copyWith(favorite: !current.favorite));
    }
  }

  Future<void> _loadBranchServices(ProviderDetailsLoaded current) async {
    final branch = current.branch;
    if (branch == null) return;
    final result = await _repo.bookingServices(
      current.provider.uuid,
      branch.uuid,
    );
    if (isClosed || state is! ProviderDetailsLoaded) return;
    result.fold(
      (_) {},
      (services) => emit(
        (state as ProviderDetailsLoaded).copyWith(bookingServices: services),
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
    final result = current.bookingKind == ProviderBookingKind.service
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
