import '../data/models/provider_details_model.dart';
import '../data/models/provider_booking_model.dart';

abstract class ProviderDetailsState {
  const ProviderDetailsState();
}

class ProviderDetailsInitial extends ProviderDetailsState {
  const ProviderDetailsInitial();
}

class ProviderDetailsLoading extends ProviderDetailsState {
  const ProviderDetailsLoading();
}

class ProviderDetailsNotFound extends ProviderDetailsState {
  const ProviderDetailsNotFound();
}

class ProviderDetailsError extends ProviderDetailsState {
  final String message;
  const ProviderDetailsError([this.message = '']);
}

class ProviderDetailsLoaded extends ProviderDetailsState {
  final ProviderDetailsModel provider;
  final int branchIndex;
  final Set<String> selectedIds;
  final String? specialistId;
  final bool favorite;
  final bool branchLoading;
  final ProviderBookingKind bookingKind;
  final ProviderBookingStep bookingStep;
  final String? packageId, entitlementId;
  final List<ProviderEmployeeModel> bookingEmployees;
  final bool allowAnyEmployee, bookingLoading, bookingSubmitting;
  final List<ProviderBookingDateModel> bookingDates;
  final DateTime? bookingDate;
  final List<ProviderBookingSlotModel> bookingSlots;
  final String? slotToken, bookingError;
  final bool waitlistEnabled, bookingCompleted, waitlistJoined;
  const ProviderDetailsLoaded(
    this.provider, {
    this.branchIndex = 0,
    this.selectedIds = const {},
    this.specialistId,
    this.favorite = false,
    this.branchLoading = false,
    this.bookingKind = ProviderBookingKind.service,
    this.bookingStep = ProviderBookingStep.employee,
    this.packageId,
    this.entitlementId,
    this.bookingEmployees = const [],
    this.allowAnyEmployee = true,
    this.bookingLoading = false,
    this.bookingSubmitting = false,
    this.bookingDates = const [],
    this.bookingDate,
    this.bookingSlots = const [],
    this.slotToken,
    this.bookingError,
    this.waitlistEnabled = false,
    this.bookingCompleted = false,
    this.waitlistJoined = false,
  });
  ProviderBranchModel? get branch =>
      provider.branches.isEmpty ? null : provider.branches[branchIndex];
  List<ProviderServiceModel> get availableServices => provider.services;

  List<ProviderEmployeeModel> get availableEmployees {
    final branchUuid = branch?.uuid;
    return provider.employees
        .where((employee) => employee.isAvailableAtBranch(branchUuid))
        .toList(growable: false);
  }

  List<ProviderServiceModel> get selectedServices => availableServices
      .where((item) => selectedIds.contains(item.uuid))
      .toList();
  double get totalPrice =>
      selectedServices.fold(0, (sum, service) => sum + service.price);
  int get totalMinutes => selectedServices.fold(
    0,
    (sum, service) => sum + (service.durationMinutes ?? 0),
  );
  ProviderDetailsLoaded copyWith({
    ProviderDetailsModel? provider,
    int? branchIndex,
    Set<String>? selectedIds,
    String? specialistId,
    bool clearSpecialist = false,
    bool? favorite,
    bool? branchLoading,
    ProviderBookingKind? bookingKind,
    ProviderBookingStep? bookingStep,
    Object? packageId = _keep,
    Object? entitlementId = _keep,
    List<ProviderEmployeeModel>? bookingEmployees,
    bool? allowAnyEmployee,
    bool? bookingLoading,
    bool? bookingSubmitting,
    List<ProviderBookingDateModel>? bookingDates,
    Object? bookingDate = _keep,
    List<ProviderBookingSlotModel>? bookingSlots,
    Object? slotToken = _keep,
    Object? bookingError = _keep,
    bool? waitlistEnabled,
    bool? bookingCompleted,
    bool? waitlistJoined,
  }) => ProviderDetailsLoaded(
    provider ?? this.provider,
    branchIndex: branchIndex ?? this.branchIndex,
    selectedIds: Set.unmodifiable(selectedIds ?? this.selectedIds),
    specialistId: clearSpecialist ? null : specialistId ?? this.specialistId,
    favorite: favorite ?? this.favorite,
    branchLoading: branchLoading ?? this.branchLoading,
    bookingKind: bookingKind ?? this.bookingKind,
    bookingStep: bookingStep ?? this.bookingStep,
    packageId: identical(packageId, _keep)
        ? this.packageId
        : packageId as String?,
    entitlementId: identical(entitlementId, _keep)
        ? this.entitlementId
        : entitlementId as String?,
    bookingEmployees: bookingEmployees ?? this.bookingEmployees,
    allowAnyEmployee: allowAnyEmployee ?? this.allowAnyEmployee,
    bookingLoading: bookingLoading ?? this.bookingLoading,
    bookingSubmitting: bookingSubmitting ?? this.bookingSubmitting,
    bookingDates: bookingDates ?? this.bookingDates,
    bookingDate: identical(bookingDate, _keep)
        ? this.bookingDate
        : bookingDate as DateTime?,
    bookingSlots: bookingSlots ?? this.bookingSlots,
    slotToken: identical(slotToken, _keep)
        ? this.slotToken
        : slotToken as String?,
    bookingError: identical(bookingError, _keep)
        ? this.bookingError
        : bookingError as String?,
    waitlistEnabled: waitlistEnabled ?? this.waitlistEnabled,
    bookingCompleted: bookingCompleted ?? this.bookingCompleted,
    waitlistJoined: waitlistJoined ?? this.waitlistJoined,
  );
}

const _keep = Object();
