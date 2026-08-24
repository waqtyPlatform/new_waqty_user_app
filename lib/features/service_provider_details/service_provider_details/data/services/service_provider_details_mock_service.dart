import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_package_offers.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/package_offer_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_service.dart';

class ServiceProviderDetailsMockService
    implements ServiceProviderDetailsService {
  const ServiceProviderDetailsMockService();

  static Either<Failure, T> _lift<T>(Either<String, T> result) => result.fold(
    (message) => Left(ServerFailure(message: message)),
    Right.new,
  );

  @override
  Future<Either<Failure, ProviderUiModel>> provider(
    String providerUuid,
  ) async => _lift(await MockSource.fetch(MockProviders.byUuid(providerUuid)));

  @override
  Future<Either<Failure, List<BranchUiModel>>> branches(
    String providerUuid,
  ) async => Right(MockProviders.branchesOf(providerUuid));

  @override
  Future<Either<Failure, List<ServiceUiModel>>> services({
    required String providerUuid,
    String? branchUuid,
  }) async => _lift(
    await MockSource.fetch(
      MockServices.ofBranch(providerUuid: providerUuid, branchUuid: branchUuid),
    ),
  );

  @override
  Future<Either<Failure, List<EmployeeUiModel>>> employees({
    required String providerUuid,
    String? branchUuid,
  }) async {
    // الموك مفهرس بالترتيب مش بالـuuid — الفهرس بيتحلّ هنا عشان الـcubit
    // مايفضلش عارف بتفصيلة دي.
    final branchIndex = MockProviders.branchIndexOf(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
    );
    return _lift(
      await MockSource.fetch(MockEmployees.rosterOf(branchIndex: branchIndex)),
    );
  }

  @override
  Future<Either<Failure, List<PackageOfferUiModel>>> packages({
    required String branchUuid,
  }) async =>
      _lift(await MockSource.fetch(MockPackageOffers.ofBranch(branchUuid)));
}
