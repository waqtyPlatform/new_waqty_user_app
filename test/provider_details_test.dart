import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/home/provider_details/data/models/provider_details_model.dart';
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
      'phone': '+201000000000',
      'rating': null,
      'rating_count': 0,
      'distance_km': null,
      'is_open_now': true,
      'branches': [
        {
          'uuid': 'branch-1',
          'name': 'Main',
          'phone': '+201111111111',
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
    expect(model.phone, '+201000000000');
    expect(model.branches.single.phone, '+201111111111');
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
}
