import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/booking_item_ui_model.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/repo/entitlements_repo.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/repo/booking_details_repo.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_state.dart';

class BookingDetailsCubit extends Cubit<BookingDetailsState> {
  final BookingDetailsRepo _repo;
  final EntitlementsRepo _entitlements;

  BookingDetailsCubit(
    this._repo,
    this._entitlements, {
    required this.bookingUuid,
  }) : super(InitialState());

  final String bookingUuid;

  BookingUiModel? booking;

  /// المتابعة اللي **الحجز ده ولّدها**، لو فيه.
  ///
  /// ## ليه بتتجاب من هنا مش من `EntitlementsCubit`
  ///
  /// شاشة التفاصيل بتتفتح بـ`pushNamed` على الـnavigator بتاع
  /// `MaterialApp` — واللي **فوق** الـproviders بتوع الـshell. يعني
  /// `EntitlementsCubit` اللي فوق التبويبات مش في نطاقها أصلاً.
  ///
  /// البدايل كانت أوحش: نسخة تانية من الكيوبت في الشجرة (مصدر حقيقة
  /// تاني)، أو رفعه فوق `MaterialApp` (بيعيش بعد تسجيل الخروج فبيسرّب
  /// باقات عميلة لعميلة تانية). فالـcubit ده بيسأل الـrepo سؤال واحد
  /// **عن الحجز ده بالذات** وبيسيب الحالة المشتركة في مكانها.
  ///
  /// TODO(api): BE-A1 — لو الحجز رجّع متابعاته في payload بتاعه، النداء
  /// الزيادة ده يتشال خالص.
  FollowUpEntitlementUiModel? followUp;

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

    final result = await _repo.booking(bookingUuid);
    if (isClosed) return;

    result.fold(
      (failure) => emit(BookingDetailsErrorState(message: failure.message)),
      (data) {
        booking = data;
        emit(BookingDetailsSuccessState());
      },
    );

    await _loadFollowUp();
  }

  /// **بيتنادى للحجز المكتمل بس.**
  ///
  /// المتابعة بتتولد لما خدمة تخلص (`follow_up_entitlements`)، فحجز جاي
  /// أو ملغي عمره ما هيبقى ليه واحدة — ونداء شبكة عشان نتأكد من حاجة
  /// مستحيلة تكلفة على كل فتحة تفاصيل.
  ///
  /// والفشل هنا **مابيكسرش الشاشة**: التفاصيل وصلت، والمتابعة إضافة.
  Future<void> _loadFollowUp() async {
    final current = booking;
    if (current == null || current.status != BookingStatus.completed) return;

    final result = await _entitlements.followUps();
    if (isClosed) return;

    result.fold((_) {}, (rows) {
      for (final row in rows) {
        if (row.originalBookingUuid == current.uuid && row.availableCount > 0) {
          followUp = row;
          emit(BookingDetailsSuccessState());
          return;
        }
      }
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

    final result = await _repo.cancel(
      bookingUuid: bookingUuid,
      reason: reason,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        // ⚠ فشل الإلغاء **لازم يبان**. أوضح حالة: السيرفر
        // بيرفض لما الميعاد يكون فات (`can_cancel` بقت false جوّه
        // الـ٥ دقايق اللي العميل فتح فيهم الورقة). لو سكتنا، العميل
        // يفتكر الحجز اتلغى ومايروحش — والصالون يسجّله ما حضرش.
        emit(BookingDetailsErrorState(message: failure.message));
      },
      (updated) {
        booking = updated;
        cancelReasonController.clear();
        emit(CancelSuccessState());
      },
    );
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

    final result = await _repo.rate(
      bookingUuid: bookingUuid,
      bookingItemUuid: item.uuid,
      rating: myRating,
      comment: comment,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(BookingDetailsErrorState(message: failure.message)),
      (_) {
        // **`pending` مش `published`.** السيرفر بيعمل التقييم
        // `status: 'pending', active: false` وبيفضل مخفي لحد المراجعة.
        // لو وريناه منشور على طول، العميل يروح يدوّر عليه ومايلاقيهوش.
        item.rating = myRating;
        item.ratingStatus = RatingStatus.pending;
        item.ratingComment = comment;

        rateCommentController.clear();
        ratingItem = null;
        emit(RateSuccessState());
      },
    );
  }

  @override
  Future<void> close() {
    cancelReasonController.dispose();
    rateCommentController.dispose();
    return super.close();
  }

  static BookingDetailsCubit get(context) => BlocProvider.of(context);
}
