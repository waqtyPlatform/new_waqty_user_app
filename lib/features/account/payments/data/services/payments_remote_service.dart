import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/core/models/payment_ui_model.dart';
import 'package:waqty_user_application/features/account/payments/data/services/payments_service.dart';

class PaymentsRemoteService implements PaymentsService {
  final ApiClient _client;

  const PaymentsRemoteService(this._client);

  @override
  Future<Either<Failure, PaginatedUiModel<PaymentUiModel>>> payments({
    int page = 1,
    int perPage = 15,
  }) => _client.get(
    ApiPaths.payments,
    query: {'page': page, 'per_page': perPage},
    parse: (envelope) => PaginatedUiModel<PaymentUiModel>.fromJson(
      {'data': envelope.data, 'meta': envelope.meta},
      PaymentUiModel.fromJson,
    ),
  );
}
