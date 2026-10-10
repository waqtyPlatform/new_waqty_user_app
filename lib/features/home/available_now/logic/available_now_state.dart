sealed class AvailableNowState {
  const AvailableNowState();
}

class AvailableNowInitialState extends AvailableNowState {
  const AvailableNowInitialState();
}

class AvailableNowLoadingState extends AvailableNowState {
  const AvailableNowLoadingState();
}

class AvailableNowLoadedState extends AvailableNowState {
  const AvailableNowLoadedState();
}

class AvailableNowErrorState extends AvailableNowState {
  final String message;

  const AvailableNowErrorState(this.message);
}
