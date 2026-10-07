import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/provider_details_repo.dart';
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
    result.fold(
      (failure) => emit(
        failure is ProviderDetailsNotFoundFailure
            ? const ProviderDetailsNotFound()
            : ProviderDetailsError(failure.message),
      ),
      (provider) => emit(ProviderDetailsLoaded(provider)),
    );
  }

  void selectTab(ProviderDetailsTab tab) {
    final current = state;
    if (current is ProviderDetailsLoaded) emit(current.copyWith(tab: tab));
  }

  void toggleService(String id) {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        !current.provider.services.any((item) => item.uuid == id)) {
      return;
    }
    final selected = {...current.selectedIds};
    if (!selected.add(id)) selected.remove(id);
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

  void selectBranch(int index) {
    final current = state;
    if (current is! ProviderDetailsLoaded ||
        index < 0 ||
        index >= current.provider.branches.length ||
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
