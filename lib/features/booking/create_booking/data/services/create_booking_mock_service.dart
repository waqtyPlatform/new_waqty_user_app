import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/mock/mock_slots.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/models/slot_ui_model.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/models/slot_taken_failure.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/services/create_booking_service.dart';

/// ⚠ **الـmock ده بيفضل للأبد.**
///
/// `slotLostAtConfirm` (حد خطف الميعاد بينك وبين التأكيد) و`branchClosedToday`
/// و`twoBranchesDifferentPricing` — دي الحالات اللي الويزارد اتصمّم حواليها،
/// و**السيرفر مايقدرش يطلّعها عند الطلب**. المراجعة من غيرها بتبقى على
/// المسار السعيد بس.
class CreateBookingMockService implements CreateBookingService {
  const CreateBookingMockService();

  static Either<Failure, T> _lift<T>(Either<String, T> result) =>
      result.fold((message) => Left(ServerFailure(message: message)), Right.new);

  @override
  Future<Either<Failure, List<BranchUiModel>>> branches(
    String providerUuid,
  ) async => Right(MockProviders.branchesOf(providerUuid));

  @override
  Future<Either<Failure, List<ServiceUiModel>>> services({
    required String providerUuid,
    String? branchUuid,
  }) async => Right(
    MockServices.ofBranch(providerUuid: providerUuid, branchUuid: branchUuid),
  );

  @override
  Future<Either<Failure, List<EmployeeUiModel>>> availableEmployees({
    required String branchUuid,
    required String serviceUuid,
  }) async => Right(MockEmployees.forService(serviceUuid));

  @override
  Future<Either<Failure, List<DateTime>>> availableDates({
    required String branchUuid,
    required String serviceUuid,
    required DateTime month,
    String? employeeUuid,
  }) async => _lift(
    await MockSource.fetchList(
      // ⚠ المدة مش معروفة هنا — الموك بياخدها من الـcubit عادةً. الافتراضي
      // ٤٥ هو نفس ما كان قبل الربط، والقيمة الحقيقية بتوصل من الـremote.
      MockSlots.availableDates(month: month, durationMinutes: 45),
    ),
  );

  @override
  Future<Either<Failure, List<SlotUiModel>>> availableSlots({
    required String branchUuid,
    required String serviceUuid,
    required DateTime date,
    String? employeeUuid,
  }) async => _lift(
    await MockSource.fetchList(
      MockSlots.slotsFor(
        date: date,
        durationMinutes: 45,
        basePrice: 0,
        anyAvailable: employeeUuid == null || employeeUuid.isEmpty,
      ),
    ),
  );

  /// السيناريو بيوقّع **أول محاولة بس**.
  ///
  /// من غير الحارس ده الحجز كان يقع كل مرة: العميل يختار بديل، يدوس
  /// تأكيد، ويقع تاني — حلقة مقفولة مالهاش مخرج. والسيناريو المفروض يوري
  /// **التعافي**، والتعافي معناه إنك تقدر تكمّل في الآخر.
  static bool _scenarioFired = false;

  /// بيرجّع الحالة لأول الجلسة — بيتنادى من مبدّل السيناريوهات.
  static void resetScenario() => _scenarioFired = false;

  @override
  Future<Either<Failure, String>> createBooking(
    Map<String, dynamic> payload,
  ) async {
    await Future.delayed(MockConfig.effectiveDelay);

    final taken = _takenServiceUuids(payload);
    if (taken.isNotEmpty) {
      _scenarioFired = true;
      return Left(SlotTakenFailure(serviceUuids: taken));
    }

    return const Right('mock-booking-uuid');
  }

  /// **أنهي خدمات ميعادها راح؟** — محاكاة، مالهاش مقابل على السيرفر.
  ///
  /// قاعدتين:
  ///
  ///  • `slotLostAtConfirm` بيخلي **أول خدمة** تقع — عشان الحالة تبقى
  ///    قابلة للعرض في تانيتين بدل ما نفضل نجرّب مواعيد لحد ما واحد يقع.
  ///  • غير كده: أي ميعاد الدقيقة فيه `:15`. القاعدة دي عشوائية شوية
  ///    (بتعتمد إن العميل يصادف يختارها) بس بتخلي الحالة قابلة للتجريب
  ///    من غير جهازين.
  List<String> _takenServiceUuids(Map<String, dynamic> payload) {
    final items = <Map<String, dynamic>>[
      for (final visit in (payload['visits'] as List? ?? const []))
        if (visit is Map<String, dynamic>)
          for (final item in (visit['items'] as List? ?? const []))
            if (item is Map<String, dynamic>) item,
    ];

    if (items.isEmpty) return const <String>[];

    if (MockConfig.scenario == MockScenario.slotLostAtConfirm) {
      if (_scenarioFired) return const <String>[];
      return [items.first['service_uuid'] as String? ?? ''];
    }

    return [
      for (final item in items)
        if ((item['start_at'] as String? ?? '').contains(':15:'))
          item['service_uuid'] as String? ?? '',
    ]..removeWhere((uuid) => uuid.isEmpty);
  }

  @override
  Future<Either<Failure, Unit>> joinWaitlist({
    required String branchUuid,
    required String serviceUuid,
    required DateTime preferredAt,
    String? employeeUuid,
    String notes = '',
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);
    MockWaitlist.add(
      providerUuid: '',
      branchUuid: branchUuid,
      serviceUuid: serviceUuid,
      preferredAt: preferredAt,
      employeeUuid: employeeUuid,
    );
    return const Right(unit);
  }
}
