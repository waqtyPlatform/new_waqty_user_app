import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/core/models/payment_ui_model.dart';

abstract class PaymentsService {
  Future<Either<Failure, PaginatedUiModel<PaymentUiModel>>> payments({
    int page = 1,
    int perPage = 15,
  });
}
