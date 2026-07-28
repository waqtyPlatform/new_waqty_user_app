import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_categories.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/features/providers/providers_list/logic/providers_list_state.dart';

class ProvidersListCubit extends Cubit<ProvidersListState> {
  ProvidersListCubit({String? initialCategoryUuid})
    : selectedCategoryUuid = initialCategoryUuid ?? '',
      super(InitialState());

  final TextEditingController searchController = TextEditingController();

  List<CategoryUiModel> categories = <CategoryUiModel>[];
  List<ProviderUiModel> providers = <ProviderUiModel>[];
  String selectedCategoryUuid;

  Future<void> loadInitial() async {
    categories = MockCategories.all;
    await search();
  }

  Future<void> search() async {
    emit(ProvidersListLoadingState());

    // TODO(api): GET /api/public/providers?search=&category_uuid=
    final result = await MockSource.fetchList(
      MockProviders.search(
        searchController.text,
        categoryUuid: selectedCategoryUuid,
      ),
    );

    result.fold((failure) => emit(ProvidersListErrorState(message: failure)), (
      data,
    ) {
      providers = data;
      emit(
        data.isEmpty ? ProvidersListEmptyState() : ProvidersListSuccessState(),
      );
    });
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
