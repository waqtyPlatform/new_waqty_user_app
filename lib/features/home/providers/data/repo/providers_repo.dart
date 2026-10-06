import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/home/providers/data/models/provider_model.dart';
import '../services/providers_service.dart';

class ProvidersRepo {
  final ProvidersService _service;

  ProvidersRepo(this._service);

  Future<Either<Failure, List<ProviderModel>>> list({
    String? categoryUuid,
    String? subcategoryUuid,
    String? query,
    String? sort,
    double? minRating,
    int limit = 10,
  }) async {
    try {
      return Right(await _service.list(
        categoryUuid: categoryUuid,
        subcategoryUuid: subcategoryUuid,
        query: query,
        sort: sort,
        minRating: minRating,
        limit: limit,
      ));
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }
}
