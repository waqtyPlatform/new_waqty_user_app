import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_state.dart';

class BookingDetailsCubit extends Cubit<BookingDetailsState> {
  BookingDetailsCubit({required this.bookingUuid}) : super(InitialState());

  final String bookingUuid;

  BookingUiModel? booking;

  final TextEditingController cancelReasonController = TextEditingController();
  final TextEditingController rateCommentController = TextEditingController();

  /// الخدمة اللي بتتقيّم دلوقتي.
  ///
  /// **التقييم بقى لكل خدمة مش للحجز.** التقييمات في السيرفر مربوطة بـ
  /// `booking_item_id` بـ unique constraint، فحجز بتلات خدمات = تلات
  /// تقييمات مستقلة. `myRating` القديمة كانت رقم واحد للحجز كله — شكل
  /// غلط مش رقم غلط، ومكانش فيه تعديل fixtures بيصلّحه.
  BookingItemUiModel? ratingItem;

  int myRating = 0;

  Future<void> loadBooking() async {
    emit(BookingDetailsLoadingState());

    // TODO(api): GET /api/user/bookings/{uuid}
    final result = await MockSource.fetch(MockBookings.byUuid(bookingUuid));

    result.fold((failure) => emit(BookingDetailsErrorState(message: failure)), (
      data,
    ) {
      booking = data;
      emit(BookingDetailsSuccessState());
    });
  }

  /// بيفتح التقييم على خدمة بعينها.
  void startRating(BookingItemUiModel item) {
    ratingItem = item;
    myRating = item.rating ?? 0;
    rateCommentController.clear();
    emit(OnRatingChangedState());
  }

  Future<void> cancelBooking() async {
    emit(CancelLoadingState());

    // **السبب بيتبعت فعلاً.**
    //
    // كان `cancelReasonController` بيتعمل وبيتعرض وبيتـ dispose — و**محدش
    // بيقرا `.text` أبدًا**. طلب مجهود من العميل وبنرميه: أوحش من إننا
    // ما نسألش أصلاً. والسيرفر بيخزّنه في `cancellation_reason` وبيكشفه
    // في `UserBookingResource`، فهو مش حتى حقل ميت من ناحيتهم.
    final reason = cancelReasonController.text.trim();

    // TODO(api): PATCH /api/user/bookings/{uuid}/cancel
    //   body: {cancellation_reason: reason}
    await Future.delayed(const Duration(milliseconds: 700));

    MockBookings.markCancelled(bookingUuid, reason: reason);
    cancelReasonController.clear();

    emit(CancelSuccessState());
  }

  void changeRating(int value) {
    myRating = value;
    emit(OnRatingChangedState());
  }

  Future<void> submitRating() async {
    final item = ratingItem;
    if (item == null) return;

    emit(RateLoadingState());

    // **التعليق بيتقرا فعلاً** — نفس اللي اتعمل في `cancelBooking` فوق.
    //
    // `rateCommentController` كان بيتعمل وبيتمسح وبيتربط في الشاشة
    // وبيتـ dispose، و**محدش بيقرا `.text`**. العميل بيكتب رأيه في خدمة
    // خلصت وبنرميه.
    //
    // ⚠ المواصفة الحالية بتاخد `booking_item_id` والنجوم بس، فالحقل ده
    // **طلب للباك إند**. بس ده مايبررش إننا نسأل ونرمي.
    final comment = rateCommentController.text.trim();

    // TODO(api): POST /api/user/bookings/{uuid}/rate
    //   الـ body بياخد `booking_item_id` — التقييم للخدمة مش للحجز.
    //   و`comment` لسه مش في العقد — طلب مفتوح للباك إند.
    await Future.delayed(const Duration(milliseconds: 700));

    // **`pending` مش `published`.** السيرفر بيعمل التقييم
    // `status: 'pending', active: false` وبيفضل مخفي لحد المراجعة.
    // لو وريناه منشور على طول، العميل يروح يدوّر عليه ومايلاقيهوش.
    item.rating = myRating;
    item.ratingStatus = RatingStatus.pending;
    item.ratingComment = comment;

    rateCommentController.clear();
    ratingItem = null;
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
