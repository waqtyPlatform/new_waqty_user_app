import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_service.dart';

class EntitlementsRemoteService implements EntitlementsService {
  final ApiClient _client;

  const EntitlementsRemoteService(this._client);

  @override
  Future<Either<Failure, List<PackageEntitlementUiModel>>> packages() =>
      _client.get(
        ApiPaths.entitlementPackages,
        // `ApiResponse::success($rows)` — ليستة مش مرقّمة. العميلة عندها
        // باقات معدودة، فمفيش ترقيم أصلاً على السيرفر.
        parse: (envelope) => <PackageEntitlementUiModel>[
          for (final row in JsonParse.mapListValue(envelope.data))
            PackageEntitlementUiModel.fromJson(row),
        ],
      );

  @override
  Future<Either<Failure, List<FollowUpEntitlementUiModel>>> followUps() =>
      _client.get(
        ApiPaths.entitlementFollowUps,
        parse: (envelope) => <FollowUpEntitlementUiModel>[
          for (final row in JsonParse.mapListValue(envelope.data))
            FollowUpEntitlementUiModel.fromJson(row),
        ],
      );

  @override
  Future<Either<Failure, Unit>> bookFollowUp({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? employeeUuid,
    String? notes,
  }) => _client.post(
    ApiPaths.bookFollowUp(uuid),
    body: <String, dynamic>{
      'booking_date': bookingDate,
      'start_time': startTime,
      if (employeeUuid != null && employeeUuid.isNotEmpty)
        'employee_uuid': employeeUuid,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    },
    // ⚠ **الجسم مابيتقراش عن قصد.** الرد `Booking` خام مش
    // `UserBookingResource` (BE-A2)، فأسماء حقوله بتاعت Eloquent وممكن
    // تتغيّر من غير ما ده يبقى كسر عقد. القراية منه بتبني اعتماد على شكل
    // محدش وعد بيه.
    parse: (_) => unit,
  );
}
