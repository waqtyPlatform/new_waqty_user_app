import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/features/home/subcategories/data/models/subcategory_model.dart';
import '../services/subcategories_service.dart';

class SubcategoriesRepo {
  final SubcategoriesService _service;

  SubcategoriesRepo(this._service);

  Future<Either<Failure, List<SubcategoryModel>>> list({
    required String categoryUuid,
    String? query,
    String? countryCode,
  }) async {
    try {
      return Right(
        await _service.list(
          categoryUuid: categoryUuid,
          query: query,
          countryCode: countryCode,
        ),
      );
    } on ServerException catch (failure) {
      return Left(ServerFailure(message: failure.serverFailure.message));
    } catch (failure) {
      return Left(ServerFailure(message: failure.toString()));
    }
  }
}
