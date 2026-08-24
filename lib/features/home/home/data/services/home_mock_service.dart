import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_categories.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_service.dart';

/// نفس عقد [HomeService] بس من الفكسشرز.
///
/// ⚠ `MockSource` بيرجّع `Either<String, T>` والعقد عايز `Either<Failure, T>` —
/// التحويل بيحصل هنا في مكان واحد بدل ما كل cubit يتعامل مع نوعين.
class HomeMockService implements HomeService {
  const HomeMockService();

  /// `Left` نص → `Left` [ServerFailure]. الرسالة بتفضل زي ما هي.
  static Either<Failure, T> _lift<T>(Either<String, T> result) =>
      result.fold((message) => Left(ServerFailure(message: message)), Right.new);

  @override
  Future<Either<Failure, List<CategoryUiModel>>> categories() async =>
      _lift(await MockSource.fetchList(MockCategories.all));

  @override
  Future<Either<Failure, List<ProviderUiModel>>> providers({
    String? cityUuid,
  }) async => _lift(await MockSource.fetchList(MockProviders.all));

  @override
  Future<Either<Failure, BookingUiModel?>> upcomingBooking() async {
    final bookings = MockBookings.upcoming;
    return Right(bookings.isEmpty ? null : bookings.first);
  }

  @override
  Future<Either<Failure, BookingUiModel?>> lastCompletedBooking() async {
    final past = MockBookings.past
        .where((b) => b.status == BookingStatus.completed)
        .toList();
    return Right(past.isEmpty ? null : past.first);
  }
}
