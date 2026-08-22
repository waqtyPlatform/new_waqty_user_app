import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
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
  Future<Either<Failure, Unit>> bookPackageSession({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? serviceUuid,
    String? notes,
  });

  /// حجز متابعة.
  ///
  /// بيرجّع [Unit] مش الحجز الجديد — `bookFollowUp` بيرجّع **موديل خام**
  /// مش `UserBookingResource`، فأسماء الحقول بتاعت Eloquent مش بتاعت الـAPI
  /// وماينفعش نعتمد على قراية `uuid` منه. لما 201 توصل، بنروح «حجوزاتي»
  /// ونعمل refresh — ده صادق وبيكلّف سطر.
  ///
  /// TODO(api): BE-A2 — لما يرجّع مورد، ده يرجّع `BookingUiModel`.
  Future<Either<Failure, Unit>> bookFollowUp({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? employeeUuid,
    String? notes,
  });
}
