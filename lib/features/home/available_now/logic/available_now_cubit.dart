import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/available_now/logic/available_now_state.dart';
import 'package:waqty_user_application/features/home/home/data/models/available_now_model.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';

class AvailableNowCubit extends Cubit<AvailableNowState> {
  final HomeRepo _homeRepo;

  AvailableNowCubit(this._homeRepo) : super(const AvailableNowInitialState());

  List<AvailableNowModel> items = const [];
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;
  int _page = 0;

  Future<void> load({bool loadMore = false}) async {
    if (loading || loadingMore || (loadMore && !hasMore)) return;

    if (loadMore) {
      loadingMore = true;
    } else {
      loading = true;
    }
    emit(const AvailableNowLoadingState());

    final requestedPage = loadMore ? _page + 1 : 1;
    final result = await _homeRepo.availableNow(page: requestedPage, limit: 10);
    if (isClosed) return;

    loading = false;
    loadingMore = false;
    result.fold((failure) => emit(AvailableNowErrorState(failure.message)), (
      page,
    ) {
      items = loadMore ? [...items, ...page.items] : page.items;
      _page = page.page;
      hasMore = page.hasMore;
      emit(const AvailableNowLoadedState());
    });
  }

  Future<void> refresh() => load();

  Future<void> loadMore() => load(loadMore: true);
}
