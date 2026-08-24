import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/services/reassignment_service.dart';

class ReassignmentRemoteService implements ReassignmentService {
  final ApiClient _client;

  const ReassignmentRemoteService(this._client);

  @override
  Future<Either<Failure, List<ReassignmentUiModel>>> list() => _client.get(
    ApiPaths.reassignments,
    parse: (envelope) => JsonParse.mapListValue(
      envelope.data,
    ).map(ReassignmentUiModel.fromJson).toList(),
  );

  @override
  Future<Either<Failure, ReassignmentUiModel>> detail(String uuid) =>
      _client.get(
        ApiPaths.reassignment(uuid),
        parse: (envelope) =>
            ReassignmentUiModel.fromJson(JsonParse.mapValue(envelope.data)),
      );

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String uuid,
    required String body,
  }) => _client.post(
    ApiPaths.reassignmentMessages(uuid),
    // حد ١٠٠٠ حرف على السيرفر — الشاشة بتقصّه قبل ما يوصل هنا.
    body: {'message': body},
    parse: (_) => unit,
  );

  @override
  Future<Either<Failure, Unit>> acceptProposal(String proposalUuid) =>
      _client.post(ApiPaths.acceptProposal(proposalUuid), parse: (_) => unit);

  @override
  Future<Either<Failure, Unit>> requestChange({
    required String proposalUuid,
    required String note,
  }) => _client.post(
    ApiPaths.requestProposalChange(proposalUuid),
    body: {'note': note},
    parse: (_) => unit,
  );

  @override
  Future<Either<Failure, Unit>> cancelProposal(String proposalUuid) =>
      _client.post(ApiPaths.cancelProposal(proposalUuid), parse: (_) => unit);
}
