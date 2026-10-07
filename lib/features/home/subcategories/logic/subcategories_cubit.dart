import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/subcategories/data/repo/subcategories_repo.dart';
import 'subcategories_state.dart';

class SubcategoriesCubit extends Cubit<SubcategoriesState> {
  final SubcategoriesRepo _repo;
  bool _requestInFlight = false;
  bool _reloadAfterCurrentRequest = false;
  String query = '';

  SubcategoriesCubit(this._repo) : super(const SubcategoriesInitialState());

  Future<void> loadSubcategories({
    required String categoryUuid,
    String? query,
    String? countryCode,
    bool force = false,
  }) async {
    if (query != null) this.query = query.trim();
    if (_requestInFlight) {
      _reloadAfterCurrentRequest = true;
      return;
    }
    if (!force && state.subcategories.isNotEmpty) return;
    _requestInFlight = true;
    emit(SubcategoriesLoadingState(state.subcategories));
    try {
      final result = await _repo.list(
        categoryUuid: categoryUuid,
        query: this.query,
        countryCode: countryCode,
      );
      result.fold(
        (_) => emit(SubcategoriesErrorState(state.subcategories)),
        (items) => emit(SubcategoriesLoadedState(items)),
      );
    } finally {
      _requestInFlight = false;
      if (_reloadAfterCurrentRequest) {
        _reloadAfterCurrentRequest = false;
        await loadSubcategories(categoryUuid: categoryUuid, force: true);
      }
    }
  }

  Future<void> search({required String categoryUuid, required String value}) {
    return loadSubcategories(
      categoryUuid: categoryUuid,
      query: value,
      force: true,
    );
  }
}
