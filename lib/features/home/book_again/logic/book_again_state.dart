sealed class BookAgainState {
  const BookAgainState();
}

class BookAgainInitialState extends BookAgainState {
  const BookAgainInitialState();
}

class BookAgainLoadingState extends BookAgainState {
  const BookAgainLoadingState();
}

class BookAgainLoadedState extends BookAgainState {
  const BookAgainLoadedState();
}

class BookAgainErrorState extends BookAgainState {
  final String message;

  const BookAgainErrorState(this.message);
}
