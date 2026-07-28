abstract class MyBookingsState {}

class InitialState extends MyBookingsState {}

class MyBookingsLoadingState extends MyBookingsState {}

class MyBookingsSuccessState extends MyBookingsState {}

class MyBookingsEmptyState extends MyBookingsState {}

class MyBookingsErrorState extends MyBookingsState {
  final String message;
  MyBookingsErrorState({required this.message});
}

class OnTabChangedState extends MyBookingsState {}
