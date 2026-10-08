import 'provider_details_model.dart';

enum ProviderBookingKind { service, package }

enum ProviderBookingStep { employee, date, slot, complete }

class ProviderBookingEmployeesModel {
  final bool allowAnyEmployee;
  final List<ProviderEmployeeModel> employees;
  const ProviderBookingEmployeesModel({
    required this.allowAnyEmployee,
    required this.employees,
  });

  factory ProviderBookingEmployeesModel.fromData(dynamic data) {
    if (data is List) {
      return ProviderBookingEmployeesModel(
        allowAnyEmployee: true,
        employees: data
            .whereType<Map<String, dynamic>>()
            .map(ProviderEmployeeModel.fromJson)
            .toList(growable: false),
      );
    }
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final employees = map['employees'];
    return ProviderBookingEmployeesModel(
      allowAnyEmployee: map['allow_any_employee'] != false,
      employees: employees is List
          ? employees
                .whereType<Map<String, dynamic>>()
                .map(ProviderEmployeeModel.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

class ProviderBookingDateModel {
  final DateTime date;
  final bool available;
  final int slotsCount;
  const ProviderBookingDateModel({
    required this.date,
    required this.available,
    required this.slotsCount,
  });
  factory ProviderBookingDateModel.fromJson(Map<String, dynamic> json) =>
      ProviderBookingDateModel(
        date: DateTime.parse(json['date'].toString()),
        available: json['available'] == true,
        slotsCount: int.tryParse(json['slots_count']?.toString() ?? '') ?? 0,
      );
}

class ProviderBookingSlotModel {
  final String startsAt, endsAt;
  final String? employeeUuid;
  final String slotToken;
  const ProviderBookingSlotModel({
    required this.startsAt,
    required this.endsAt,
    required this.slotToken,
    this.employeeUuid,
  });
  factory ProviderBookingSlotModel.fromJson(Map<String, dynamic> json) =>
      ProviderBookingSlotModel(
        startsAt: _text(json['starts_at'] ?? json['start_time']),
        endsAt: _text(json['ends_at'] ?? json['end_time']),
        employeeUuid: _nullable(json['employee_uuid']),
        slotToken: json['slot_token']?.toString() ?? '',
      );
}

class ProviderBookingSlotsModel {
  final List<ProviderBookingSlotModel> slots;
  final bool waitlistEnabled;
  final String? waitlistReason;
  const ProviderBookingSlotsModel({
    required this.slots,
    required this.waitlistEnabled,
    this.waitlistReason,
  });
  factory ProviderBookingSlotsModel.fromData(dynamic data) {
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final rawSlots = map['slots'];
    final slots = rawSlots is List
        ? rawSlots
              .whereType<Map<String, dynamic>>()
              .map(ProviderBookingSlotModel.fromJson)
              .toList(growable: false)
        : <ProviderBookingSlotModel>[];
    final waitlist = map['waitlist'] is Map<String, dynamic>
        ? map['waitlist'] as Map<String, dynamic>
        : <String, dynamic>{};
    return ProviderBookingSlotsModel(
      slots: slots,
      waitlistEnabled: waitlist['enabled'] == true || slots.isEmpty,
      waitlistReason: _nullable(waitlist['reason']),
    );
  }
}

String? _nullable(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

String _text(dynamic value) => value?.toString().trim() ?? '';
