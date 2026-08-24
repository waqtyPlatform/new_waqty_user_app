import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_payments.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/core/models/payment_ui_model.dart';
import 'package:waqty_user_application/features/account/payments/data/services/payments_service.dart';

class PaymentsMockService implements PaymentsService {
  const PaymentsMockService();

  @override
  Future<Either<Failure, PaginatedUiModel<PaymentUiModel>>> payments({
    int page = 1,
    int perPage = 15,
  }) async =>
      (await MockSource.fetchPage(
        MockPayments.all,
        page: page,
        perPage: perPage,
      )).fold((message) => Left(ServerFailure(message: message)), Right.new);
}
