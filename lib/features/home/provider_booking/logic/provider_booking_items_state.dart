import '../data/models/provider_booking_items_model.dart';

class ProviderBookingItemsState {
  final ProviderBookingItemType type;
  final bool loading, continuing;
  final String? error, selectedUuid;
  final ProviderBookingCatalogueModel? catalogue;
  final ProviderBookingEntitlementsModel? entitlements;

  const ProviderBookingItemsState({
    this.type = ProviderBookingItemType.services,
    this.loading = false,
    this.continuing = false,
    this.error,
    this.selectedUuid,
    this.catalogue,
    this.entitlements,
  });

  ProviderBookingItemsState copyWith({
    ProviderBookingItemType? type,
    bool? loading,
    bool? continuing,
    Object? error = _keep,
    Object? selectedUuid = _keep,
    ProviderBookingCatalogueModel? catalogue,
    ProviderBookingEntitlementsModel? entitlements,
    bool clearCatalogue = false,
    bool clearEntitlements = false,
  }) => ProviderBookingItemsState(
    type: type ?? this.type,
    loading: loading ?? this.loading,
    continuing: continuing ?? this.continuing,
    error: identical(error, _keep) ? this.error : error as String?,
    selectedUuid: identical(selectedUuid, _keep)
        ? this.selectedUuid
        : selectedUuid as String?,
    catalogue: clearCatalogue ? null : catalogue ?? this.catalogue,
    entitlements: clearEntitlements ? null : entitlements ?? this.entitlements,
  );
}

const _keep = Object();
