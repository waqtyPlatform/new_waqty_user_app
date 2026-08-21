import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/providers/providers_list/data/services/providers_list_service.dart';

class ProvidersListRemoteService implements ProvidersListService {
  final ApiClient _client;

  const ProvidersListRemoteService(this._client);

  @override
  Future<Either<Failure, List<CategoryUiModel>>> categories() => _client.get(
    ApiPaths.categories,
    parse: (envelope) => JsonParse.mapListValue(
      envelope.data,
    ).map(CategoryUiModel.fromJson).toList(),
  );

  @override
  Future<Either<Failure, PaginatedUiModel<ProviderUiModel>>> search({
    String query = '',
    String categoryUuid = '',
    int page = 1,
    int perPage = 15,
  }) => _client.get(
    ApiPaths.providers,
    // القيم الفاضية بتتشال في `HttpConsumer._uri`، فمفيش `?search=` فاضية
    // بتوصل السيرفر وتفلتر على نص فاضي.
    query: {
      if (query.trim().isNotEmpty) 'search': query.trim(),
      if (categoryUuid.isNotEmpty) 'category_uuid': categoryUuid,
      'page': page,
      'per_page': perPage,
    },
    // ⚠ الظرف كله بيتمرّر لـ`PaginatedUiModel` مش `envelope.data` بس —
    // التقسيم في `meta.pagination`، والداتا في `data`.
    parse: (envelope) => PaginatedUiModel<ProviderUiModel>.fromJson(
      {'data': envelope.data, 'meta': envelope.meta},
      (json) => ProviderUiModel.fromJson(json),
    ),
  );
}
