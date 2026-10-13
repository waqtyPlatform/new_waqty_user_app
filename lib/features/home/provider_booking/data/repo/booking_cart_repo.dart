import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';

import '../models/booking_cart_model.dart';
import '../services/booking_cart_service.dart';

class BookingCartFailure extends Failure {
  final String code;
  final List<String> expiredItemUuids;

  const BookingCartFailure({
    required this.code,
    required super.message,
    this.expiredItemUuids = const [],
  });
}

class BookingCartRepo {
  final BookingCartService _service;
  const BookingCartRepo(this._service);

  Future<Either<Failure, BookingCartModel?>> getCart() =>
      _guard(_service.getCart);

  Future<Either<Failure, BookingCartModel>> addItem(
    BookingCartAddRequest request,
  ) => _guard(() => _service.addItem(request));

  Future<Either<Failure, BookingCartModel?>> updateItem({
    required String itemUuid,
    required String slotToken,
    String? employeeUuid,
  }) => _guard(
    () => _service.updateItem(
      itemUuid: itemUuid,
      slotToken: slotToken,
      employeeUuid: employeeUuid,
    ),
  );

  Future<Either<Failure, BookingCartModel?>> deleteItem(String itemUuid) =>
      _guard(() => _service.deleteItem(itemUuid));

  Future<Either<Failure, void>> clear() => _guard(_service.clear);

  Future<Either<Failure, BookingCartCheckoutModel>> checkout({
    required String cartUuid,
    required String idempotencyKey,
  }) => _guard(
    () => _service.checkout(cartUuid: cartUuid, idempotencyKey: idempotencyKey),
  );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on BookingCartApiException catch (failure) {
      return Left(
        BookingCartFailure(
          code: failure.code,
          message: failure.message,
          expiredItemUuids: failure.expiredItemUuids,
        ),
      );
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }
}
