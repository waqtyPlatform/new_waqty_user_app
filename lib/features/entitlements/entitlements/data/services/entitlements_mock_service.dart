import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_entitlements.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/entitlement_owner_ui_model.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_service.dart';

class EntitlementsMockService implements EntitlementsService {
  const EntitlementsMockService();

  static Either<Failure, T> _lift<T>(Either<String, T> result) => result.fold(
    (message) => Left(ServerFailure(message: message)),
    Right.new,
  );

  @override
  Future<Either<Failure, List<PackageEntitlementUiModel>>> packages() async =>
      _lift(await MockSource.fetchList(MockEntitlements.packages));

  @override
  Future<Either<Failure, List<FollowUpEntitlementUiModel>>> followUps() async =>
      _lift(await MockSource.fetchList(MockEntitlements.followUps));

  @override
  Future<Either<Failure, BookingUiModel>> bookPackageSession({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? serviceUuid,
    String? notes,
  }) {
    final package = MockEntitlements.packages
        .where((p) => p.uuid == uuid)
        .firstOrNull;

    return _book(
      startAt: _startAt(bookingDate, startTime),
      serviceUuid: serviceUuid ?? package?.slotServiceUuid ?? '',
      serviceName: switch (package) {
        SessionPackageEntitlement(:final serviceName) => serviceName,
        UsagePackageEntitlement(:final allowedServices) =>
          allowedServices.isEmpty ? 'جلسة' : allowedServices.first.name,
        null => 'جلسة',
      },
      durationMinutes: switch (package) {
        SessionPackageEntitlement(:final durationMinutes) => durationMinutes,
        UsagePackageEntitlement(:final allowedServices) =>
          allowedServices.isEmpty ? 45 : allowedServices.first.durationMinutes,
        null => 45,
      },
      owner: package?.owner ?? EntitlementOwnerUiModel.unknown,
    );
  }

  @override
  Future<Either<Failure, BookingUiModel>> bookFollowUp({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? employeeUuid,
    String? notes,
  }) {
    final followUp = MockEntitlements.followUps
        .where((f) => f.uuid == uuid)
        .firstOrNull;

    return _book(
      startAt: _startAt(bookingDate, startTime),
      serviceUuid: followUp?.serviceUuid ?? '',
      serviceName: followUp == null
          ? 'متابعة'
          : 'متابعة ${followUp.serviceName}',
      durationMinutes: followUp?.durationMinutes ?? 15,
      owner: followUp?.owner ?? EntitlementOwnerUiModel.unknown,
    );
  }

  /// `Y-m-d` + `HH:mm` — نفس اللي الكيوبت بيبعته للسيرفر.
  static DateTime _startAt(String bookingDate, String startTime) {
    final parts = startTime.split(':');
    final day = DateTime.parse(bookingDate);
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.tryParse(parts.first) ?? 0,
      parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  /// النوعين بيشتركوا في نفس حالات الفشل — الفرق على السيرفر مش هنا.
  Future<Either<Failure, BookingUiModel>> _book({
    required DateTime startAt,
    required String serviceUuid,
    required String serviceName,
    required int durationMinutes,
    required EntitlementOwnerUiModel owner,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);

    if (MockConfig.isErrorForced) {
      return const Left(ServerFailure(message: MockConfig.errorMessage));
    }

    // ⚠ **الميعاد اللي راح — الحالة اللي السيرفر مايقدرش يطلّعها عند الطلب.**
    //
    // بين ما العميلة تختار الميعاد وتدوس تأكيد، ممكن حد يخطفه. ده 422
    // حقيقي بيرجع من `PackageBookingService`، والشيت **لازم يفضل مفتوح**
    // برسالة السيرفر عشان ماتضيعش اختيارها.
    if (MockConfig.scenario == MockScenario.slotLostAtConfirm) {
      return const Left(
        ValidationFailure(
          message: 'الميعاد ده اتحجز توّه — اختار ميعاد تاني',
          fields: <String, List<String>>{
            'start_time': <String>['الميعاد ده اتحجز توّه — اختار ميعاد تاني'],
          },
        ),
      );
    }

    return Right(
      MockBookings.justBooked(
        startAt: startAt,
        durationMinutes: durationMinutes,
        serviceUuid: serviceUuid,
        serviceName: serviceName,
        providerUuid: owner.providerUuid,
        providerName: owner.providerName,
        branchUuid: owner.branchUuid,
        branchName: owner.branchName,
      ),
    );
  }
}
