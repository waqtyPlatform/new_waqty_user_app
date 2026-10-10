sealed class TopRatedState {
  const TopRatedState();
}

class TopRatedInitialState extends TopRatedState {
  const TopRatedInitialState();
}

class TopRatedLoadingState extends TopRatedState {
  const TopRatedLoadingState();
}

class TopRatedLoadedState extends TopRatedState {
  const TopRatedLoadedState();
}

class TopRatedErrorState extends TopRatedState {
  final String message;

  const TopRatedErrorState(this.message);
}
