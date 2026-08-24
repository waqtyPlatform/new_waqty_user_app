import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';

abstract class ProvidersListService {
  Future<Either<Failure, List<CategoryUiModel>>> categories();

  /// ⚠ **بترجّع صفحة مش لستة.**
  ///
  /// السيرفر بيقسّم ١٥/صفحة. الـcubit كان بيقرا اللستة كاملة وبيعرض أول
  /// ١٥ **من غير أي إشارة إن فيه كمان** — القايمة بتتقطع في صمت.
  Future<Either<Failure, PaginatedUiModel<ProviderUiModel>>> search({
    String query = '',
    String categoryUuid = '',
    int page = 1,
    int perPage = 15,
  });
}
