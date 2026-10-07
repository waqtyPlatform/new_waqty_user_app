import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/provider_details_model.dart';
import '../data/repo/provider_details_repo.dart';
import 'provider_details_state.dart';

class ProviderDetailsCubit extends Cubit<ProviderDetailsState> {
  final ProviderDetailsRepo _repo;
  int _generation = 0;
  ProviderDetailsCubit(this._repo) : super(const ProviderDetailsInitial());
  Future<void> initialize(ProviderDetailsModel provider) async {
    final generation = ++_generation;
    emit(const ProviderDetailsLoading());
    try {
      final catalog = await _repo.loadPreview();
      if (isClosed || generation != _generation) return;
      emit(
        ProviderDetailsLoaded(
          provider,
          catalog,
          selectedIds: const {'hair', 'beard'},
        ),
      );
    } catch (_) {
      if (!isClosed && generation == _generation) {
        emit(const ProviderDetailsError());
      }
    }
  }

  void selectTab(ProviderDetailsTab tab) {
    final current = state;
    if (current is ProviderDetailsLoaded) emit(current.copyWith(tab: tab));
  }

  void toggleService(String id) {
    final current = state;
    if (current is! ProviderDetailsLoaded) return;
    final valid = current.branch.services.any(
      (s) =>
          s.children.isEmpty ? s.id == id : s.children.any((c) => c.id == id),
    );
    if (!valid) return;
    final selected = {...current.selectedIds};
    if (!selected.add(id)) selected.remove(id);
    emit(current.copyWith(selectedIds: selected));
  }

  void selectSpecialist(String? id) {
    final current = state;
    if (current is! ProviderDetailsLoaded) return;
    if (id != null && !current.branch.specialists.any((s) => s.id == id)) {
      return;
    }
    emit(current.copyWith(specialistId: id, clearSpecialist: id == null));
  }

  void selectBranch(int index) {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        index < 0 ||
        index >= current.catalog.branches.length ||
        index == current.branchIndex) {
      return;
    }
    emit(
      current.copyWith(
        branchIndex: index,
        selectedIds: {},
        clearSpecialist: true,
      ),
    );
  }

  void toggleFavorite() {
    final current = state;
    if (current is ProviderDetailsLoaded) {
      emit(current.copyWith(favorite: !current.favorite));
    }
  }
}
