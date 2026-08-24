import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/features/providers/providers_list/data/repo/providers_list_repo.dart';
import 'package:waqty_user_application/features/providers/providers_list/logic/providers_list_state.dart';

class ProvidersListCubit extends Cubit<ProvidersListState> {
  final ProvidersListRepo _repo;

  ProvidersListCubit(this._repo, {String? initialCategoryUuid})
    : selectedCategoryUuid = initialCategoryUuid ?? '',
      super(InitialState());

  final TextEditingController searchController = TextEditingController();

  List<CategoryUiModel> categories = <CategoryUiModel>[];
  List<ProviderUiModel> providers = <ProviderUiModel>[];
  String selectedCategoryUuid;

  static const int perPage = 15;

  int _page = 1;

  /// **المصدر الوحيد لـ«فيه كمان؟»** — من رقم السيرفر مش من طول القايمة.
  bool hasMore = false;

  bool isLoadingMore = false;

  Future<void> loadInitial() async {
    final result = await _repo.categories();
    categories = result.getOrElse(() => <CategoryUiModel>[]);
    await search();
  }

  Future<void> search() async {
    emit(ProvidersListLoadingState());

    _page = 1;
    hasMore = false;
    isLoadingMore = false;

    // **الفلاتر بتتصوّر قبل الانتظار.**
    //
    // لو العميل غيّر التصنيف والطلب لسه شغّال، الرد الراجع بتاع الفلتر
    // **القديم** كان هيتحط مكان الجديد. نفس حارس `MyBookingsCubit`.
    final requestedQuery = searchController.text;
    final requestedCategory = selectedCategoryUuid;

    final result = await _repo.search(
      query: requestedQuery,
      categoryUuid: requestedCategory,
      page: 1,
      perPage: perPage,
    );

    if (isClosed) return;
    if (searchController.text != requestedQuery ||
        selectedCategoryUuid != requestedCategory) {
      return;
    }

    result.fold(
      (failure) => emit(ProvidersListErrorState(message: failure.message)),
      (page) {
        providers = page.data;
        _page = page.currentPage;
        hasMore = page.hasMore;
        emit(
          page.isEmpty
              ? ProvidersListEmptyState()
              : ProvidersListSuccessState(),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    emit(ProvidersListLoadingMoreState());

    final requestedQuery = searchController.text;
    final requestedCategory = selectedCategoryUuid;

    final result = await _repo.search(
      query: requestedQuery,
      categoryUuid: requestedCategory,
      page: _page + 1,
      perPage: perPage,
    );

    if (isClosed) return;
    isLoadingMore = false;

    if (searchController.text != requestedQuery ||
        selectedCategoryUuid != requestedCategory) {
      return;
    }

    result.fold(
      (_) {
        // فشل صفحة إضافية **مش** بيمسح اللي قدام العميل. `hasMore` بتتقفل
        // عشان التحميل التلقائي مايفضلش يحاول في كل سكرول.
        hasMore = false;
        emit(ProvidersListSuccessState());
      },
      (page) {
        providers = [...providers, ...page.data];
        _page = page.currentPage;
        hasMore = page.hasMore;
        emit(ProvidersListSuccessState());
      },
    );
  }

  /// الضغط على نفس التصنيف بيلغي الاختيار — عشان العميل يقدر يرجع
  /// للكل من غير ما يدوّر على زرار «مسح».
  void changeCategory(String categoryUuid) {
    selectedCategoryUuid = selectedCategoryUuid == categoryUuid
        ? ''
        : categoryUuid;
    emit(OnFilterChangedState());
    search();
  }

  void clearFilters() {
    searchController.clear();
    selectedCategoryUuid = '';
    emit(OnFilterChangedState());
    search();
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }

  static ProvidersListCubit get(context) => BlocProvider.of(context);
}
