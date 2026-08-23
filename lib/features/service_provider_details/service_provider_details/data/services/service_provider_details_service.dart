import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/package_offer_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';

abstract class ServiceProviderDetailsService {
  Future<Either<Failure, ProviderUiModel>> provider(String providerUuid);

  Future<Either<Failure, List<BranchUiModel>>> branches(String providerUuid);

  Future<Either<Failure, List<ServiceUiModel>>> services({
    required String providerUuid,
    String? branchUuid,
  });

  Future<Either<Failure, List<EmployeeUiModel>>> employees({
    required String providerUuid,
    String? branchUuid,
  });

  /// الباقات اللي **الفرع ده** بيبيعها.
  ///
  /// ⚠ الفرع مش المزوّد. نفس الصالون ممكن يبيع نفس الباقة بسعر تاني في
  /// فرع تاني، و`packages.branch_id` على السيرفر بيقول كده.
  Future<Either<Failure, List<PackageOfferUiModel>>> packages({
    required String branchUuid,
  });
}
