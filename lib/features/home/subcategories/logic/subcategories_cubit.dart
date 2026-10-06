import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/subcategories/data/repo/subcategories_repo.dart';
import 'subcategories_state.dart';

class SubcategoriesCubit extends Cubit<SubcategoriesState> {
  final SubcategoriesRepo _repo;
  bool _requestInFlight = false;

  SubcategoriesCubit(this._repo) : super(const SubcategoriesInitialState());

  Future<void> loadSubcategories({
    required String categoryUuid,
    String? query,
    String? countryCode,
    bool force = false,
  }) async {
    if (_requestInFlight || (!force && state.subcategories.isNotEmpty)) return;
    _requestInFlight = true;
    emit(SubcategoriesLoadingState(state.subcategories));
    try {
      final result = await _repo.list(
        categoryUuid: categoryUuid,
        query: query,
        countryCode: countryCode,
      );
      result.fold(
        (_) => emit(SubcategoriesErrorState(state.subcategories)),
        (items) => emit(SubcategoriesLoadedState(items)),
      );
    } finally {
      _requestInFlight = false;
    }
  }
}
