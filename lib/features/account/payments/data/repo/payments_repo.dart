import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/core/models/payment_ui_model.dart';
import 'package:waqty_user_application/features/account/payments/data/services/payments_service.dart';

class PaymentsRepo extends BaseRepo<PaymentsService> {
  const PaymentsRepo(super.remote, super.mock);

  Future<Either<Failure, PaginatedUiModel<PaymentUiModel>>> payments({
    int page = 1,
    int perPage = 15,
  }) => guard(() => source.payments(page: page, perPage: perPage));
}
