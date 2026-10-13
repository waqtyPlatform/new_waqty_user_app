import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/home/provider_booking/data/models/provider_booking_items_model.dart';
import 'package:waqty_user_application/features/home/provider_booking/data/repo/provider_booking_items_repo.dart';
import 'package:waqty_user_application/features/home/provider_booking/data/services/provider_booking_items_service.dart';
import 'package:waqty_user_application/features/home/provider_booking/logic/provider_booking_items_cubit.dart';
import 'package:waqty_user_application/features/home/provider_details/data/models/provider_details_model.dart';

class _Api extends Fake implements ApiConsumer {}

class _Repo extends ProviderBookingItemsRepo {
  _Repo() : super(ProviderBookingItemsService(apiConsumer: _Api()));

  @override
  Future<Either<Failure, ProviderBookingCatalogueModel>> catalogue({
    required String providerUuid,
    required String branchUuid,
    required ProviderBookingItemType type,
  }) async => Right(
    ProviderBookingCatalogueModel(
      providerUuid: providerUuid,
      providerName: 'Provider',
      branchUuid: branchUuid,
      branchName: 'Branch',
      services: type == ProviderBookingItemType.services
          ? [
              ProviderServiceModel(
                uuid: 'service-1',
                name: 'Haircut',
                price: 100,
                priceMax: 100,
              ),
            ]
          : const [],
      packages: type == ProviderBookingItemType.packages
          ? [
              ProviderPackageModel(
                uuid: 'package-1',
                name: 'Package',
                originalTotal: 120,
                price: 100,
              ),
            ]
          : const [],
    ),
  );

  @override
  Future<Either<Failure, ProviderBookingEntitlementsModel>> entitlements({
    required String providerUuid,
    required String branchUuid,
    required ProviderBookingItemType type,
    String status = 'active',
  }) async => Right(
    ProviderBookingEntitlementsModel(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
      status: status,
      packages: type == ProviderBookingItemType.ownedPackages
          ? const [
              ProviderBookingEntitlementModel(
                uuid: 'owned-1',
                name: 'Owned package',
                status: 'active',
              ),
            ]
          : const [],
      followUps: type == ProviderBookingItemType.followUps
          ? const [
              ProviderBookingEntitlementModel(
                uuid: 'follow-up-1',
                name: 'Follow-up',
                status: 'active',
                serviceUuid: 'service-1',
              ),
            ]
          : const [],
    ),
  );
}

void main() {
  test('parses catalogue response contract', () {
    final model = ProviderBookingCatalogueModel.fromJson({
      'provider': {'uuid': 'provider-1', 'name': 'Provider'},
      'branch': {'uuid': 'branch-1', 'name': 'Branch'},
      'type': 'services',
      'currency_code': 'SAR',
      'services': [
        {
          'uuid': 'service-1',
          'name': 'Haircut',
          'description': 'Classic cut',
          'price': 100,
          'price_max': 100,
        },
      ],
      'packages': [],
      'services_count': 1,
      'packages_count': 0,
    });

    expect(model.providerUuid, 'provider-1');
    expect(model.branchUuid, 'branch-1');
    expect(model.currencyCode, 'SAR');
    expect(model.services.single.name, 'Haircut');
    expect(model.servicesCount, 1);
  });

  test('parses entitlement response contract', () {
    final model = ProviderBookingEntitlementsModel.fromJson({
      'provider_uuid': 'provider-1',
      'branch_uuid': 'branch-1',
      'type': 'packages',
      'status': 'active',
      'packages': [
        {
          'uuid': 'owned-1',
          'package_name': 'Hair package',
          'package_uuid': 'package-1',
          'remaining_sessions': 3,
          'expires_at': '2026-12-31',
          'status': 'active',
        },
      ],
      'follow_ups': [],
      'packages_count': 1,
      'follow_ups_count': 0,
      'has_entitlements': true,
    });

    expect(model.hasEntitlements, isTrue);
    expect(model.packages.single.name, 'Hair package');
    expect(model.packages.single.remainingSessions, 3);
    expect(model.packages.single.packageUuid, 'package-1');
  });

  test('loads one type and keeps only one selected item', () async {
    final cubit = ProviderBookingItemsCubit(
      _Repo(),
      providerUuid: 'provider-1',
      branchUuid: 'branch-1',
    );

    await cubit.load();
    expect(cubit.state.catalogue?.services.single.uuid, 'service-1');
    cubit.selectItem('service-1');
    expect(cubit.state.selectedUuid, 'service-1');

    await cubit.load(ProviderBookingItemType.ownedPackages);
    expect(cubit.state.selectedUuid, isNull);
    expect(cubit.state.entitlements?.packages.single.uuid, 'owned-1');
    cubit.selectItem('owned-1');
    expect(cubit.state.selectedUuid, 'owned-1');
    expect(cubit.beginContinue(), isTrue);
    expect(cubit.state.continuing, isTrue);
    expect(cubit.beginContinue(), isFalse);
    cubit.finishContinue();
    expect(cubit.state.continuing, isFalse);
    await cubit.close();
  });

  test('refresh preserves a valid selection in all four tabs', () async {
    final cubit = ProviderBookingItemsCubit(
      _Repo(),
      providerUuid: 'provider-1',
      branchUuid: 'branch-1',
    );
    final selections = <ProviderBookingItemType, String>{
      ProviderBookingItemType.services: 'service-1',
      ProviderBookingItemType.packages: 'package-1',
      ProviderBookingItemType.ownedPackages: 'owned-1',
      ProviderBookingItemType.followUps: 'follow-up-1',
    };

    for (final entry in selections.entries) {
      await cubit.load(entry.key);
      cubit.selectItem(entry.value);
      await cubit.refresh();
      expect(cubit.state.type, entry.key);
      expect(cubit.state.selectedUuid, entry.value);
    }
    await cubit.close();
  });
}
