import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/provider_booking_items_model.dart';
import '../data/repo/provider_booking_items_repo.dart';
import 'provider_booking_items_state.dart';

class ProviderBookingItemsCubit extends Cubit<ProviderBookingItemsState> {
  final ProviderBookingItemsRepo _repo;
  final String providerUuid, branchUuid;
  int _requestId = 0;

  ProviderBookingItemsCubit(
    this._repo, {
    required this.providerUuid,
    required this.branchUuid,
    String? selectedServiceUuid,
  }) : super(ProviderBookingItemsState(selectedUuid: selectedServiceUuid));

  Future<void> load([ProviderBookingItemType? requestedType]) async {
    await _load(requestedType ?? state.type);
  }

  Future<void> refresh() async {
    await _load(state.type, preserveContent: true);
  }

  Future<void> _load(
    ProviderBookingItemType type, {
    bool preserveContent = false,
  }) async {
    final requestId = ++_requestId;
    final selectedUuid = preserveContent
        ? state.selectedUuid
        : type == ProviderBookingItemType.services
        ? state.selectedUuid
        : null;
    emit(
      state.copyWith(
        type: type,
        loading: !preserveContent,
        error: null,
        selectedUuid: selectedUuid,
        clearCatalogue: !preserveContent,
        clearEntitlements: !preserveContent,
      ),
    );

    if (type == ProviderBookingItemType.services ||
        type == ProviderBookingItemType.packages) {
      final result = await _repo.catalogue(
        providerUuid: providerUuid,
        branchUuid: branchUuid,
        type: type,
      );
      if (isClosed || requestId != _requestId) return;
      result.fold(
        (failure) =>
            emit(state.copyWith(loading: false, error: failure.message)),
        (catalogue) => emit(
          state.copyWith(
            loading: false,
            catalogue: catalogue,
            selectedUuid:
                _catalogueContains(catalogue, type, state.selectedUuid)
                ? state.selectedUuid
                : null,
          ),
        ),
      );
      return;
    }

    final result = await _repo.entitlements(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
      type: type,
    );
    if (isClosed || requestId != _requestId) return;
    result.fold(
      (failure) => emit(state.copyWith(loading: false, error: failure.message)),
      (entitlements) => emit(
        state.copyWith(
          loading: false,
          entitlements: entitlements,
          selectedUuid:
              _entitlementsContain(entitlements, type, state.selectedUuid)
              ? state.selectedUuid
              : null,
        ),
      ),
    );
  }

  bool _catalogueContains(
    ProviderBookingCatalogueModel catalogue,
    ProviderBookingItemType type,
    String? uuid,
  ) {
    if (uuid == null) return false;
    return type == ProviderBookingItemType.services
        ? catalogue.services.any((item) => item.uuid == uuid)
        : catalogue.packages.any((item) => item.uuid == uuid);
  }

  bool _entitlementsContain(
    ProviderBookingEntitlementsModel entitlements,
    ProviderBookingItemType type,
    String? uuid,
  ) {
    if (uuid == null) return false;
    final items = type == ProviderBookingItemType.ownedPackages
        ? entitlements.packages
        : entitlements.followUps;
    return items.any((item) => item.uuid == uuid);
  }

  void selectType(ProviderBookingItemType type) {
    if (type == state.type) return;
    load(type);
  }

  void selectItem(String uuid) {
    if (uuid.isEmpty) return;
    emit(
      state.copyWith(selectedUuid: state.selectedUuid == uuid ? null : uuid),
    );
  }

  bool beginContinue() {
    if (state.continuing) return false;
    emit(state.copyWith(continuing: true));
    return true;
  }

  void finishContinue() {
    if (!state.continuing) return;
    emit(state.copyWith(continuing: false));
  }
}
