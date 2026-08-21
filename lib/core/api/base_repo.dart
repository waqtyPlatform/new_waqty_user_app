import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/data_source.dart';
import 'package:waqty_user_application/core/exceptions/exceptions.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';

/// أساس كل repo: بيختار المصدر، وبيضمن إن مفيش استثناء بيطلع للـcubit.
///
/// ## ليه الاختيار في الـrepo مش نسختين منه
///
/// جسم الـrepo كله `try/catch → Either` **متطابق** للمصدرين. لو عملنا
/// `RemoteHomeRepo` و`MockHomeRepo` بنضاعف ~٢٠ ملف، وبيبقى فيه مكانين
/// لتحويل الأخطاء يقدروا يفترقوا في صمت.
///
/// فالـrepo واحد، و[source] هي السطر الوحيد اللي بيفرّق.
///
/// ```dart
/// class HomeRepo extends BaseRepo<HomeService> {
///   HomeRepo(super.remote, super.mock);
///
///   Future<Either<Failure, List<CategoryUiModel>>> categories() =>
///       guard(() => source.categories());
/// }
/// ```
abstract class BaseRepo<S> {
  final S _remote;
  final S _mock;

  const BaseRepo(this._remote, this._mock);

  /// المصدر الشغال دلوقتي — بيتقرا **عند كل نداء** مش مرة واحدة، عشان
  /// التبديل من المبدّل ياخد أثره فورًا.
  S get source => DataSource.isMock ? _mock : _remote;

  /// بتلف أي نداء وترجّع [Failure] بدل ما ترمي.
  ///
  /// الـ`RemoteService` بيرجّع `Either` أصلاً من [ApiClient]، فده حزام أمان
  /// لأي حاجة برّاه: تحويل موديل بيرمي، أو `MockService` بيرمي، أو
  /// [ServerException] قديم من الـauth services.
  Future<Either<Failure, T>> guard<T>(
    Future<Either<Failure, T>> Function() call,
  ) async {
    try {
      return await call();
    } on ServerException catch (e) {
      return Left(e.serverFailure);
    } catch (_) {
      return const Left(ServerFailure(message: ServerFailure.fallbackMessage));
    }
  }
}
