import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';

/// اللي العميلة **مالكاه** — باقات اشترتها ومتابعات استحقّتها.
///
/// النوعين بيتحجزوا من التطبيق دلوقتي. قبل BE-A1 كانت الباقات بتتعرض
/// وبس، لأن الرد مكانش فيه فرع فمكانش فيه مواعيد نعرضها.
abstract class EntitlementsService {
  Future<Either<Failure, List<PackageEntitlementUiModel>>> packages();

  Future<Either<Failure, List<FollowUpEntitlementUiModel>>> followUps();

  /// حجز جلسة من باقة.
  ///
  /// `service_uuid` بيتبعت للبركة بس — السيرفر بيتجاهله في باقات الجلسات
  /// وبياخد خدمة الشراء نفسها (`$purchase->service->uuid`).
  Future<Either<Failure, BookingUiModel>> bookPackageSession({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? serviceUuid,
    String? notes,
  });

  /// حجز متابعة — **بيرجّع الحجز اللي اتعمل**.
  ///
  /// كان بيرجّع [Unit]: الـendpoint كان بيرد بموديل `Booking` خام، فأسماء
  /// حقوله بتاعت Eloquent وشكله بيتغيّر مع أي migration، والقراية منه كانت
  /// هتبني اعتماد على شكل محدش وعد بيه. بعد BE-A2 بقى بيرد
  /// بـ`UserBookingResource` — **نفس اللي `GET /user/bookings/{uuid}`
  /// بيرجّعه** — فبقى فيه عقد نقرا منه.
  Future<Either<Failure, BookingUiModel>> bookFollowUp({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? employeeUuid,
    String? notes,
  });
}
