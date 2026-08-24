import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';

abstract class BookingDetailsService {
  Future<Either<Failure, BookingUiModel>> booking(String bookingUuid);

  /// بترجّع الحجز بعد الإلغاء — الحالة و`cancelled_at` بيتحدّثوا من السيرفر
  /// مش بالإيد.
  Future<Either<Failure, BookingUiModel>> cancel({
    required String bookingUuid,
    required String reason,
  });

  /// ⚠ التقييم **للخدمة مش للحجز** — `booking_item_uuid` بيحدد أنهي خدمة.
  ///
  /// السيرفر بيعمله `status: pending, active: false` وبيفضل مخفي لحد
  /// المراجعة، فالشاشة لازم توري «مستني المراجعة» مش «اتنشر».
  Future<Either<Failure, Unit>> rate({
    required String bookingUuid,
    required String bookingItemUuid,
    required int rating,
    String comment = '',
  });
}
