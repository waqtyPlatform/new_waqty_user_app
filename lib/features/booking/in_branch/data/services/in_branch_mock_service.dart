import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_in_branch.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/services/in_branch_service.dart';

class InBranchMockService implements InBranchService {
  const InBranchMockService();

  @override
  Future<Either<Failure, InBranchUiModel?>> status(
    BookingUiModel booking,
  ) async => Right(MockInBranch.forBooking(booking, DateTime.now()));
}
