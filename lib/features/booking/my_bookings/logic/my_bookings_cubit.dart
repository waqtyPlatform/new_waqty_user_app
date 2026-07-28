import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  MyBookingsCubit() : super(InitialState());

  List<BookingUiModel> bookings = <BookingUiModel>[];

  /// ٠ = القادمة · ١ = السابقة
  int selectedTab = 0;

  void changeTab(int value) {
    selectedTab = value;
    emit(OnTabChangedState());
    loadBookings();
  }

  Future<void> loadBookings() async {
    emit(MyBookingsLoadingState());

    // TODO(api): GET /api/user/bookings?upcoming=true / ?past=true
    final result = await MockSource.fetchList(
      selectedTab == 0 ? MockBookings.upcoming : MockBookings.past,
    );

    result.fold((failure) => emit(MyBookingsErrorState(message: failure)), (
      data,
    ) {
      bookings = data;
      emit(data.isEmpty ? MyBookingsEmptyState() : MyBookingsSuccessState());
    });
  }

  static MyBookingsCubit get(context) => BlocProvider.of(context);
}
