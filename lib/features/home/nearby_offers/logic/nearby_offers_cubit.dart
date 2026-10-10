import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/home/home/data/models/nearby_offer_model.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/nearby_offers/logic/nearby_offers_state.dart';

class NearbyOffersCubit extends Cubit<NearbyOffersState> {
  final HomeRepo _homeRepo;

  NearbyOffersCubit(this._homeRepo) : super(const NearbyOffersInitialState());

  List<NearbyOfferModel> items = const [];
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
    emit(const NearbyOffersLoadingState());

    final requestedPage = loadMore ? _page + 1 : 1;
    final result = await _homeRepo.nearbyOffers(page: requestedPage, limit: 10);
    if (isClosed) return;

    loading = false;
    loadingMore = false;
    result.fold((failure) => emit(NearbyOffersErrorState(failure.message)), (
      page,
    ) {
      items = loadMore ? [...items, ...page.items] : page.items;
      _page = page.page;
      hasMore = page.hasMore;
      emit(const NearbyOffersLoadedState());
    });
  }

  Future<void> refresh() => load();

  Future<void> loadMore() => load(loadMore: true);
}
