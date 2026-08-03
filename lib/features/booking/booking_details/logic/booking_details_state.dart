abstract class BookingDetailsState {}

class InitialState extends BookingDetailsState {}

class BookingDetailsLoadingState extends BookingDetailsState {}

class BookingDetailsSuccessState extends BookingDetailsState {}

class BookingDetailsErrorState extends BookingDetailsState {
  final String message;
  BookingDetailsErrorState({required this.message});
}

class CancelLoadingState extends BookingDetailsState {}

class CancelSuccessState extends BookingDetailsState {}

class RateLoadingState extends BookingDetailsState {}

class RateSuccessState extends BookingDetailsState {}

class OnRatingChangedState extends BookingDetailsState {}
