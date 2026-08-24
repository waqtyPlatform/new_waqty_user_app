import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/services/in_branch_service.dart';

class InBranchRepo extends BaseRepo<InBranchService> {
  const InBranchRepo(super.remote, super.mock);

  Future<Either<Failure, InBranchUiModel?>> status(BookingUiModel booking) =>
      guard(() => source.status(booking));
}
