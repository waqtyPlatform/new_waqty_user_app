import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/explore/logic/explore_categories_state.dart';

class ExploreCategoriesCubit extends Cubit<ExploreCategoriesState> {
  final HomeRepo _homeRepo;

  ExploreCategoriesCubit(this._homeRepo)
    : super(const ExploreCategoriesInitialState());

  bool _requestInFlight = false;
  bool _reloadAfterCurrentRequest = false;
  String? selectedCategoryId;
  String query = '';

  Future<void> loadCategories({bool force = false}) async {
    if (_requestInFlight) {
      _reloadAfterCurrentRequest = true;
      return;
    }
    if (!force && state.categories.isNotEmpty) return;

    _requestInFlight = true;
    emit(
      ExploreCategoriesLoadingState(
        categories: state.categories,
        selectedCategoryId: selectedCategoryId,
      ),
    );
    try {
      final result = await _homeRepo.categories(query: query);
      result.fold(
        (_) => emit(
          ExploreCategoriesErrorState(
            categories: state.categories,
            selectedCategoryId: selectedCategoryId,
          ),
        ),
        (categories) => emit(
          ExploreCategoriesLoadedState(
            categories,
            selectedCategoryId: selectedCategoryId,
          ),
        ),
      );
    } finally {
      _requestInFlight = false;
      if (_reloadAfterCurrentRequest) {
        _reloadAfterCurrentRequest = false;
        await loadCategories(force: true);
      }
    }
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    emit(
      ExploreCategoriesLoadedState(
        state.categories,
        selectedCategoryId: categoryId,
      ),
    );
  }

  Future<void> search(String value) async {
    query = value.trim();
    await loadCategories(force: true);
  }
}
