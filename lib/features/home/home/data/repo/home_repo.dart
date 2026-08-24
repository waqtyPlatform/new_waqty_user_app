import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_service.dart';

class HomeRepo extends BaseRepo<HomeService> {
  const HomeRepo(super.remote, super.mock);

  Future<Either<Failure, List<CategoryUiModel>>> categories() =>
      guard(() => source.categories());

  Future<Either<Failure, List<ProviderUiModel>>> providers({
    String? cityUuid,
  }) => guard(() => source.providers(cityUuid: cityUuid));

  Future<Either<Failure, BookingUiModel?>> upcomingBooking() =>
      guard(() => source.upcomingBooking());

  Future<Either<Failure, BookingUiModel?>> lastCompletedBooking() =>
      guard(() => source.lastCompletedBooking());
}
