import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/home/data/models/top_rated_provider_model.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/top_rated/logic/top_rated_state.dart';

class TopRatedCubit extends Cubit<TopRatedState> {
  final HomeRepo _homeRepo;

  TopRatedCubit(this._homeRepo) : super(const TopRatedInitialState());

  List<TopRatedProviderModel> items = const [];
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
    emit(const TopRatedLoadingState());

    final requestedPage = loadMore ? _page + 1 : 1;
    final result = await _homeRepo.topRated(page: requestedPage, limit: 10);
    if (isClosed) return;

    loading = false;
    loadingMore = false;
    result.fold((failure) => emit(TopRatedErrorState(failure.message)), (page) {
      items = loadMore ? [...items, ...page.items] : page.items;
      _page = page.page;
      hasMore = page.hasMore;
      emit(const TopRatedLoadedState());
    });
  }

  Future<void> refresh() => load();

  Future<void> loadMore() => load(loadMore: true);
}
