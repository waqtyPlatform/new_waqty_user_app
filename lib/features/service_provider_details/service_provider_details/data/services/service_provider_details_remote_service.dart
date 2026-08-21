import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_service.dart';

class ServiceProviderDetailsRemoteService
    implements ServiceProviderDetailsService {
  final ApiClient _client;

  const ServiceProviderDetailsRemoteService(this._client);

  @override
  Future<Either<Failure, ProviderUiModel>> provider(String providerUuid) =>
      _client.get(
        ApiPaths.provider(providerUuid),
        parse: (envelope) =>
            ProviderUiModel.fromJson(JsonParse.mapValue(envelope.data)),
      );

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
    // ⚠ `providerUuid` بيتمرّر للموديل عشان يختار **عرض المقدّم ده** من
    // `providers[]` — نفس الخدمة عند مقدّمين مختلفين بسعر مختلف.
    parse: (envelope) => JsonParse.mapListValue(envelope.data)
        .map((json) => ServiceUiModel.fromJson(json, providerUuid: providerUuid))
        .toList(),
  );

  @override
  Future<Either<Failure, List<EmployeeUiModel>>> employees({
    required String providerUuid,
    String? branchUuid,
  }) => _client.get(
    ApiPaths.employees,
    query: {'provider_uuid': providerUuid, 'branch_uuid': branchUuid},
    parse: (envelope) => JsonParse.mapListValue(
      envelope.data,
    ).map((json) => EmployeeUiModel.fromJson(json)).toList(),
  );
}
