sealed class NearbyOffersState {
  const NearbyOffersState();
}

class NearbyOffersInitialState extends NearbyOffersState {
  const NearbyOffersInitialState();
}

class NearbyOffersLoadingState extends NearbyOffersState {
  const NearbyOffersLoadingState();
}

class NearbyOffersLoadedState extends NearbyOffersState {
  const NearbyOffersLoadedState();
}

class NearbyOffersErrorState extends NearbyOffersState {
  final String message;

  const NearbyOffersErrorState(this.message);
}
