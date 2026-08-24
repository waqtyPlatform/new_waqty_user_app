import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_categories.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/features/providers/providers_list/data/services/providers_list_service.dart';

class ProvidersListMockService implements ProvidersListService {
  const ProvidersListMockService();

  static Either<Failure, T> _lift<T>(Either<String, T> result) =>
      result.fold((message) => Left(ServerFailure(message: message)), Right.new);

  @override
  Future<Either<Failure, List<CategoryUiModel>>> categories() async =>
      _lift(await MockSource.fetchList(MockCategories.all));

  @override
  Future<Either<Failure, PaginatedUiModel<ProviderUiModel>>> search({
    String query = '',
    String categoryUuid = '',
    int page = 1,
    int perPage = 15,
  }) async {
    // `fetchPage` بيقلّد قصّ `LengthAwarePaginator` في الذاكرة، فالفكسشرز
    // بتمشي على نفس مسار التقسيم بتاع السيرفر.
    final result = await MockSource.fetchPage(
      MockProviders.search(query, categoryUuid: categoryUuid),
      page: page,
      perPage: perPage,
    );
    return _lift(result);
  }
}
