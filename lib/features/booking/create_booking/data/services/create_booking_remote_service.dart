import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/services/create_booking_service.dart';

class CreateBookingRemoteService implements CreateBookingService {
  final ApiClient _client;

  const CreateBookingRemoteService(this._client);

  @override
  Future<Either<Failure, List<BranchUiModel>>> branches(String providerUuid) =>
      _client.get(
        ApiPaths.providerBranches,
        query: {'provider_uuid': providerUuid},
        parse: (envelope) => JsonParse.mapListValue(
          envelope.data,
        ).map((json) => BranchUiModel.fromJson(json)).toList(),
      );

  @override
  Future<Either<Failure, List<ServiceUiModel>>> services({
    required String providerUuid,
    String? branchUuid,
  }) => _client.get(
    ApiPaths.services,
    query: {'provider_uuid': providerUuid, 'branch_uuid': branchUuid},
    parse: (envelope) => JsonParse.mapListValue(envelope.data)
        .map((json) => ServiceUiModel.fromJson(json, providerUuid: providerUuid))
        .toList(),
  );

  @override
  Future<Either<Failure, List<EmployeeUiModel>>> availableEmployees({
    required String branchUuid,
    required String serviceUuid,
  }) => _client.get(
    ApiPaths.availableEmployees,
    query: {'branch_uuid': branchUuid, 'service_uuid': serviceUuid},
    // ⚠ **الرد ملفوف في `data.employees` مش `data` مباشرة**، والسعر والمدة
    // في جذر كل موظف (`effective_price`) مش جوّه `services[]` زي
    // `public/employees`. فمينفعش نستخدم `EmployeeUiModel.fromJson` هنا.
    parse: (envelope) {
      final employees = JsonParse.mapListValue(
        JsonParse.mapValue(envelope.data)['employees'],
      );

      return employees
          .map(
            (json) => EmployeeUiModel(
              uuid: JsonParse.stringValue(json['uuid']),
              name: JsonParse.localizedValue(json['name']),
              imagePath: JsonParse.stringValue(json['logo_url']),
              price: JsonParse.doubleValue(json['effective_price']),
              durationMinutes: JsonParse.intValue(
                json['effective_duration_minutes'],
              ),
            ),
          )
          .toList();
    },
  );

  @override
  Future<Either<Failure, List<DateTime>>> availableDates({
    required String branchUuid,
    required String serviceUuid,
    required DateTime month,
    String? employeeUuid,
  }) => _client.get(
    ApiPaths.availableDates,
    query: {
      'branch_uuid': branchUuid,
      'service_uuid': serviceUuid,
      'employee_uuid': employeeUuid,
      // `Y-m` — الشهر بس، مش تاريخ كامل.
      'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
    },
    // `data.dates` لستة نصوص `"2026-09-07"` مش خرايط.
    parse: (envelope) {
      final raw = JsonParse.mapValue(envelope.data)['dates'];
      if (raw is! List) return const <DateTime>[];

      return raw
          .map((value) => JsonParse.dateOrNull(value))
          .whereType<DateTime>()
          .toList();
    },
  );

  @override
  Future<Either<Failure, List<SlotUiModel>>> availableSlots({
    required String branchUuid,
    required String serviceUuid,
    required DateTime date,
    String? employeeUuid,
  }) => _client.get(
    ApiPaths.availableSlots,
    query: {
      'branch_uuid': branchUuid,
      'service_uuid': serviceUuid,
      'employee_uuid': employeeUuid,
      'date': AppFormat.serverDate(date),
    },
    parse: (envelope) => JsonParse.mapListValue(
      JsonParse.mapValue(envelope.data)['slots'],
    )
        // السيرفر بيرجّع المواعيد المقفولة كمان بـ`available: false` —
        // العميل مايشوفش غير اللي يقدر يحجزه.
        .where((json) => JsonParse.boolValue(json['available'], fallback: true))
        .map(SlotUiModel.fromJson)
        .toList(),
  );

  @override
  Future<Either<Failure, String>> createBooking(
    Map<String, dynamic> payload,
  ) => _client.post(
    ApiPaths.bookings,
    body: payload,
    parse: (envelope) =>
        JsonParse.stringValue(JsonParse.mapValue(envelope.data)['uuid']),
  );

  @override
  Future<Either<Failure, Unit>> joinWaitlist({
    required String branchUuid,
    required String serviceUuid,
    required DateTime preferredAt,
    String? employeeUuid,
    String notes = '',
  }) => _client.post(
    ApiPaths.waitlist,
    body: {
      'branch_uuid': branchUuid,
      'service_uuid': serviceUuid,
      if (employeeUuid != null && employeeUuid.isNotEmpty)
        'employee_uuid': employeeUuid,
      // ⚠ **حقلين منفصلين.** `StoreUserWaitlistRequest` بيتحقق من
      // `preferred_date` بـ`Y-m-d` و`preferred_time` بـ`H:i` — الاتنين
      // مطلوبين. بعت `DateTime` واحد بيرجع ٤٢٢.
      'preferred_date': AppFormat.serverDate(preferredAt),
      'preferred_time':
          '${preferredAt.hour.toString().padLeft(2, '0')}:'
          '${preferredAt.minute.toString().padLeft(2, '0')}',
      if (notes.isNotEmpty) 'notes': notes,
    },
    parse: (_) => unit,
  );
}
