import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_state.dart';

class BookingDetailsCubit extends Cubit<BookingDetailsState> {
  BookingDetailsCubit({required this.bookingUuid}) : super(InitialState());

  final String bookingUuid;

  BookingUiModel? booking;

  final TextEditingController cancelReasonController = TextEditingController();
  final TextEditingController rateCommentController = TextEditingController();
  int myRating = 0;

  Future<void> loadBooking() async {
    emit(BookingDetailsLoadingState());

    // TODO(api): GET /api/user/bookings/{uuid}
    final result = await MockSource.fetch(MockBookings.byUuid(bookingUuid));

    result.fold((failure) => emit(BookingDetailsErrorState(message: failure)), (
      data,
    ) {
      booking = data;
      myRating = data.myRating;
      emit(BookingDetailsSuccessState());
    });
  }

  Future<void> cancelBooking() async {
    emit(CancelLoadingState());

    // TODO(api): PATCH /api/user/bookings/{uuid}/cancel
    await Future.delayed(const Duration(milliseconds: 700));

    emit(CancelSuccessState());
  }

  void changeRating(int value) {
    myRating = value;
    emit(OnRatingChangedState());
  }

  Future<void> submitRating() async {
    emit(RateLoadingState());

    // TODO(api): POST /api/user/bookings/{uuid}/rate
    await Future.delayed(const Duration(milliseconds: 700));

    emit(RateSuccessState());
  }

  @override
  Future<void> close() {
    cancelReasonController.dispose();
    rateCommentController.dispose();
    return super.close();
  }

  static BookingDetailsCubit get(context) => BlocProvider.of(context);
}
