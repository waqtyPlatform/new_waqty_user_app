import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/base_repo.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/features/providers/providers_list/data/services/providers_list_service.dart';

class ProvidersListRepo extends BaseRepo<ProvidersListService> {
  const ProvidersListRepo(super.remote, super.mock);

  Future<Either<Failure, List<CategoryUiModel>>> categories() =>
      guard(() => source.categories());

  Future<Either<Failure, PaginatedUiModel<ProviderUiModel>>> search({
    String query = '',
    String categoryUuid = '',
    int page = 1,
    int perPage = 15,
  }) => guard(
    () => source.search(
      query: query,
      categoryUuid: categoryUuid,
      page: page,
      perPage: perPage,
    ),
  );
}
