import '../data/models/provider_catalog.dart';
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

class ProviderDetailsError extends ProviderDetailsState {
  const ProviderDetailsError();
}

class ProviderDetailsLoaded extends ProviderDetailsState {
  final ProviderDetailsModel provider;
  final ProviderCatalog catalog;
  final int branchIndex;
  final ProviderDetailsTab tab;
  final Set<String> selectedIds;
  final String? specialistId;
  final bool favorite;
  const ProviderDetailsLoaded(
    this.provider,
    this.catalog, {
    this.branchIndex = 0,
    this.tab = ProviderDetailsTab.services,
    this.selectedIds = const {},
    this.specialistId,
    this.favorite = false,
  });
  ProviderBranch get branch => catalog.branches[branchIndex];
  List<ProviderServiceItem> get selectedServices => [
    for (final service in branch.services)
      if (service.children.isEmpty && selectedIds.contains(service.id))
        service
      else
        ...service.children.where((child) => selectedIds.contains(child.id)),
  ];
  int get totalPrice =>
      selectedServices.fold(0, (sum, service) => sum + service.price);
  int get totalMinutes =>
      selectedServices.fold(0, (sum, service) => sum + service.minutes);
  ProviderDetailsLoaded copyWith({
    int? branchIndex,
    ProviderDetailsTab? tab,
    Set<String>? selectedIds,
    String? specialistId,
    bool clearSpecialist = false,
    bool? favorite,
  }) => ProviderDetailsLoaded(
    provider,
    catalog,
    branchIndex: branchIndex ?? this.branchIndex,
    tab: tab ?? this.tab,
    selectedIds: Set.unmodifiable(selectedIds ?? this.selectedIds),
    specialistId: clearSpecialist ? null : specialistId ?? this.specialistId,
    favorite: favorite ?? this.favorite,
  );
}
