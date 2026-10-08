import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/home/provider_details/data/models/provider_details_model.dart';
import 'package:waqty_user_application/features/home/provider_details/data/models/provider_booking_model.dart';
import 'package:waqty_user_application/features/home/provider_details/data/repo/provider_details_repo.dart';
import 'package:waqty_user_application/features/home/provider_details/data/services/provider_details_service.dart';
import 'package:waqty_user_application/features/home/provider_details/logic/provider_details_cubit.dart';
import 'package:waqty_user_application/features/home/provider_details/logic/provider_details_state.dart';

class _Api extends Fake implements ApiConsumer {}

class _Repo extends ProviderDetailsRepo {
  final Either<Failure, ProviderDetailsModel> result;
  _Repo(this.result) : super(ProviderDetailsService(apiConsumer: _Api()));
  @override
  Future<Either<Failure, ProviderDetailsModel>> show(String uuid) async =>
      result;

  @override
  Future<Either<Failure, List<ProviderServiceModel>>> bookingServices(
    String providerUuid,
    String branchUuid,
  ) async => Right(provider.services);
}

class _BookingRepo extends _Repo {
  Map<String, dynamic>? submittedBooking;
  _BookingRepo() : super(const Right(provider));

  @override
  Future<Either<Failure, ProviderBookingEmployeesModel>> bookingEmployees(
    String providerUuid,
    String branchUuid,
    String serviceUuid,
  ) async => const Right(
    ProviderBookingEmployeesModel(allowAnyEmployee: true, employees: []),
  );

  @override
  Future<Either<Failure, List<ProviderBookingDateModel>>> bookingDates({
    required String providerUuid,
    required String branchUuid,
    required String serviceUuid,
    String? employeeUuid,
    required String timezone,
  }) async => Right([
    ProviderBookingDateModel(
      date: DateTime(2026, 10, 10),
      available: true,
      slotsCount: 1,
    ),
  ]);

  @override
  Future<Either<Failure, ProviderBookingSlotsModel>> bookingSlots({
    required String providerUuid,
    required String branchUuid,
    required String serviceUuid,
    String? employeeUuid,
    required DateTime date,
    required String timezone,
  }) async => const Right(
    ProviderBookingSlotsModel(
      waitlistEnabled: false,
      slots: [
        ProviderBookingSlotModel(
          startsAt: '10:00:00',
          endsAt: '10:30:00',
          slotToken: 'signed-slot',
        ),
      ],
    ),
  );

  @override
  Future<Either<Failure, void>> createBooking(Map<String, dynamic> body) async {
    submittedBooking = body;
    return const Right(null);
  }
}

const provider = ProviderDetailsModel(
  uuid: 'provider-1',
  name: 'Provider',
  rating: null,
  ratingCount: 0,
  branches: [
    ProviderBranchModel(uuid: 'branch-1', name: 'Main branch'),
    ProviderBranchModel(uuid: 'branch-2', name: 'Second branch'),
  ],
  services: [
    ProviderServiceModel(
      uuid: 'service-1',
      name: 'Haircut',
      price: 100,
      priceMax: 150,
      durationMinutes: 30,
      branchesCount: 2,
    ),
  ],
  servicesCount: 1,
);

void main() {
  test('parses nullable rating, ranges, working hours and reviews', () {
    final model = ProviderDetailsModel.fromJson({
      'uuid': 'provider-1',
      'name': 'Provider',
      'rating': null,
      'rating_count': 0,
      'distance_km': null,
      'is_open_now': true,
      'branches': [
        {
          'uuid': 'branch-1',
          'name': 'Main',
          'working_hours': [
            {
              'day_of_week': 0,
              'start_time': '09:00:00',
              'end_time': '23:00:00',
            },
          ],
        },
      ],
      'services': [
        {
          'uuid': 'service-1',
          'name': 'Haircut',
          'price': 100,
          'price_max': 150,
          'branches_count': 2,
        },
      ],
      'employees': [],
      'reviews': [
        {
          'uuid': 'review-1',
          'rating': 5,
          'comment': 'Great',
          'user_name': null,
          'created_at': '2026-10-01T12:00:00Z',
        },
      ],
    });
    expect(model.rating, isNull);
    expect(model.distanceKm, isNull);
    expect(model.services.single.priceMax, 150);
    expect(model.branches.single.workingHours.single.dayOfWeek, 0);
    expect(model.reviews.single.userName, isNull);
  });

  test('cubit loads API data and keeps selection in state', () async {
    final cubit = ProviderDetailsCubit(_Repo(const Right(provider)));
    await cubit.load(provider.uuid);
    cubit.toggleService('service-1');
    var state = cubit.state as ProviderDetailsLoaded;
    expect(state.totalPrice, 100);
    expect(state.totalMinutes, 30);
    cubit.selectBranch(1);
    state = cubit.state as ProviderDetailsLoaded;
    expect(state.selectedIds, isEmpty);
    await cubit.close();
  });

  test('404 becomes a dedicated not-found state', () async {
    final cubit = ProviderDetailsCubit(
      _Repo(const Left(ProviderDetailsNotFoundFailure())),
    );
    await cubit.load('hidden-provider');
    expect(cubit.state, isA<ProviderDetailsNotFound>());
    await cubit.close();
  });

  test('parses employee, dates and slot token contracts', () {
    final employees = ProviderBookingEmployeesModel.fromData([]);
    final slots = ProviderBookingSlotsModel.fromData({
      'slots': [
        {
          'start_time': '10:00:00',
          'end_time': '10:30:00',
          'slot_token': 'signed-slot',
        },
      ],
    });
    expect(employees.allowAnyEmployee, isTrue);
    expect(slots.slots.single.slotToken, 'signed-slot');
    expect(slots.slots.single.startsAt, '10:00:00');
  });

  test('service booking supports any employee then date and slot', () async {
    final repo = _BookingRepo();
    final cubit = ProviderDetailsCubit(repo);
    await cubit.load(provider.uuid);
    cubit.toggleService('service-1');
    await cubit.startServiceBooking();
    var state = cubit.state as ProviderDetailsLoaded;
    expect(state.allowAnyEmployee, isTrue);
    await cubit.chooseEmployee(null);
    state = cubit.state as ProviderDetailsLoaded;
    expect(state.bookingDates, hasLength(1));
    expect(state.specialistId, isNull);
    await cubit.chooseDate(state.bookingDates.single.date);
    state = cubit.state as ProviderDetailsLoaded;
    expect(state.bookingSlots.single.slotToken, 'signed-slot');
    expect(state.waitlistEnabled, isFalse);
    cubit.chooseSlot('signed-slot');
    await cubit.confirmBooking();
    expect(repo.submittedBooking?['slot_token'], 'signed-slot');
    expect(repo.submittedBooking?['employee_uuid'], isNull);
    expect(repo.submittedBooking?['service_uuid'], 'service-1');
    await cubit.close();
  });

  test('empty slots enable waitlist fallback', () {
    final slots = ProviderBookingSlotsModel.fromData({'slots': []});
    expect(slots.waitlistEnabled, isTrue);
  });
}
