import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';

/// اللي العميلة **مالكاه** — باقات اشترتها ومتابعات استحقّتها.
///
/// ⚠ **مافيش `bookPackageSession` في العقد ده.** الـendpoint موجود على
/// السيرفر (`POST /entitlements/packages/{uuid}/sessions`)، بس التطبيق
/// مايقدرش يوصله: بيحتاج `booking_date` و`start_time` من
/// `/public/bookings/available-slots`، واللي محتاج `branch_uuid` — والفرع
/// مش موجود في أي صف من صفوف الباقات (BLOCKER-1 · BE-A1).
///
/// إضافة الدالة هنا وهي مش قابلة للنداء بتخلّي الـUI يبني زرار بيفشل.
/// فالعقد بيقول الحقيقة: **الباقات بتتعرض، والمتابعات بتتحجز.**
abstract class EntitlementsService {
  Future<Either<Failure, List<PackageEntitlementUiModel>>> packages();

  Future<Either<Failure, List<FollowUpEntitlementUiModel>>> followUps();

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
