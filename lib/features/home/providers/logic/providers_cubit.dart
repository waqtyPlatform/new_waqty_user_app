import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/providers/data/repo/providers_repo.dart';
import 'providers_state.dart';

class ProvidersCubit extends Cubit<ProvidersState> {
  final ProvidersRepo _repo;
  final String? categoryUuid;
  final String? subcategoryUuid;
  bool _requestInFlight = false;
  bool _reloadAfterCurrentRequest = false;
  String? sort;
  bool nearestSelected = false;
  bool ratingSelected = false;
  double? minRating;
  String query = '';

  ProvidersCubit(
    this._repo, {
    this.categoryUuid,
    this.subcategoryUuid,
  }) : super(const ProvidersInitialState());

  Future<void> loadProviders({bool force = false}) async {
    if (_requestInFlight) {
      if (force) _reloadAfterCurrentRequest = true;
      return;
    }
    if (!force && state.providers.isNotEmpty) return;
    _requestInFlight = true;
    emit(ProvidersLoadingState(state.providers));
    try {
      final result = await _repo.list(
        categoryUuid: categoryUuid,
        subcategoryUuid: subcategoryUuid,
        query: query,
        sort: sort,
        minRating: minRating,
      );
      result.fold(
        (_) => emit(ProvidersErrorState(state.providers)),
        (items) => emit(ProvidersLoadedState(items)),
      );
    } finally {
      _requestInFlight = false;
      if (_reloadAfterCurrentRequest) {
        _reloadAfterCurrentRequest = false;
        await loadProviders(force: true);
      }
    }
  }

  Future<void> search(String value) async {
    query = value.trim();
    await loadProviders(force: true);
  }

  Future<void> applyFilter({double? minRating, String? filterKey}) async {
    if (filterKey == 'nearest') {
      nearestSelected = !nearestSelected;
    } else if (filterKey == 'rating') {
      ratingSelected = !ratingSelected;
    }
    sort = ratingSelected ? 'rating' : null;
    this.minRating = minRating;
    await loadProviders(force: true);
  }
}
