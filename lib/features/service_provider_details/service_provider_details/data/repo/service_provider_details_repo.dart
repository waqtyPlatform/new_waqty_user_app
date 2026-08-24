import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/package_offer_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_service.dart';

class ServiceProviderDetailsRepo
    extends BaseRepo<ServiceProviderDetailsService> {
  const ServiceProviderDetailsRepo(super.remote, super.mock);

  Future<Either<Failure, ProviderUiModel>> provider(String providerUuid) =>
      guard(() => source.provider(providerUuid));

  Future<Either<Failure, List<BranchUiModel>>> branches(String providerUuid) =>
      guard(() => source.branches(providerUuid));

  Future<Either<Failure, List<ServiceUiModel>>> services({
    required String providerUuid,
    String? branchUuid,
  }) => guard(
    () => source.services(providerUuid: providerUuid, branchUuid: branchUuid),
  );

  Future<Either<Failure, List<EmployeeUiModel>>> employees({
    required String providerUuid,
    String? branchUuid,
  }) => guard(
    () => source.employees(providerUuid: providerUuid, branchUuid: branchUuid),
  );

  Future<Either<Failure, List<PackageOfferUiModel>>> packages({
    required String branchUuid,
  }) => guard(() => source.packages(branchUuid: branchUuid));
}
