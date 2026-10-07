import '../data/models/provider_details_model.dart';

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
  const ProviderDetailsLoaded(
    this.provider, {
    this.branchIndex = 0,
    this.tab = ProviderDetailsTab.services,
    this.selectedIds = const {},
    this.specialistId,
    this.favorite = false,
  });
  ProviderBranchModel? get branch =>
      provider.branches.isEmpty ? null : provider.branches[branchIndex];
  List<ProviderServiceModel> get selectedServices => provider.services
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
  }) => ProviderDetailsLoaded(
    provider,
    branchIndex: branchIndex ?? this.branchIndex,
    tab: tab ?? this.tab,
    selectedIds: Set.unmodifiable(selectedIds ?? this.selectedIds),
    specialistId: clearSpecialist ? null : specialistId ?? this.specialistId,
    favorite: favorite ?? this.favorite,
  );
}
