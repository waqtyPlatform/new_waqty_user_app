import '../data/models/provider_details_model.dart';
import '../data/models/provider_booking_model.dart';

enum ProviderDetailsTab { services, specialists, packages, information }

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
  final ProviderDetailsTab tab;
  final Set<String> selectedIds;
  final String? specialistId;
  final bool favorite;
  final List<ProviderServiceModel> bookingServices;
  final ProviderBookingKind bookingKind;
  final ProviderBookingStep bookingStep;
  final String? packageId;
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
    this.tab = ProviderDetailsTab.services,
    this.selectedIds = const {},
    this.specialistId,
    this.favorite = false,
    this.bookingServices = const [],
    this.bookingKind = ProviderBookingKind.service,
    this.bookingStep = ProviderBookingStep.employee,
    this.packageId,
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
  List<ProviderServiceModel> get availableServices =>
      bookingServices.isEmpty ? provider.services : bookingServices;
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
    int? branchIndex,
    ProviderDetailsTab? tab,
    Set<String>? selectedIds,
    String? specialistId,
    bool clearSpecialist = false,
    bool? favorite,
    List<ProviderServiceModel>? bookingServices,
    ProviderBookingKind? bookingKind,
    ProviderBookingStep? bookingStep,
    Object? packageId = _keep,
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
    provider,
    branchIndex: branchIndex ?? this.branchIndex,
    tab: tab ?? this.tab,
    selectedIds: Set.unmodifiable(selectedIds ?? this.selectedIds),
    specialistId: clearSpecialist ? null : specialistId ?? this.specialistId,
    favorite: favorite ?? this.favorite,
    bookingServices: bookingServices ?? this.bookingServices,
    bookingKind: bookingKind ?? this.bookingKind,
    bookingStep: bookingStep ?? this.bookingStep,
    packageId: identical(packageId, _keep)
        ? this.packageId
        : packageId as String?,
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
