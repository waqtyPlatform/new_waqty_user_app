import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/book_again/logic/book_again_state.dart';
import 'package:waqty_user_application/features/home/home/data/models/book_again_model.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';

class BookAgainCubit extends Cubit<BookAgainState> {
  final HomeRepo _homeRepo;

  BookAgainCubit(this._homeRepo) : super(const BookAgainInitialState());

  List<BookAgainModel> items = const [];
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
    emit(const BookAgainLoadingState());

    final requestedPage = loadMore ? _page + 1 : 1;
    final result = await _homeRepo.bookAgain(page: requestedPage, limit: 10);
    if (isClosed) return;

    loading = false;
    loadingMore = false;
    result.fold((failure) => emit(BookAgainErrorState(failure.message)), (
      page,
    ) {
      items = loadMore ? [...items, ...page.items] : page.items;
      _page = page.page;
      hasMore = page.hasMore;
      emit(const BookAgainLoadedState());
    });
  }

  Future<void> refresh() => load();

  Future<void> loadMore() => load(loadMore: true);
}
