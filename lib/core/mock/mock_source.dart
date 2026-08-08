import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';

/// MOCK — يتشال كله لما كل الشاشات تتربط بالـ API
///
/// المحرّك بتاع الداتا المضروبة. بيرجّع `Either<String, T>` بنفس شكل الـ repo
/// الحقيقي بالظبط، عشان الـ Cubit يتكتب مرة واحدة بشكله النهائي — ويوم الربط
/// نغيّر سطر النداء بس، من غير ما نلمس الـ fold ولا الـ states ولا أي widget.
class MockSource {
  MockSource._();

  /// بترجّع الداتا بعد تأخير، أو خطأ لو الخطأ مفروض.
  ///
  /// بيقرا من `isErrorForced` و`effectiveDelay` مش من الحقول الخام —
  /// عشان السيناريو (`networkError`، `slowNetwork`) والسويتش اليدوي
  /// الاتنين يشتغلوا من غير ما حد يفتكر يزامنهم.
  static Future<Either<String, T>> fetch<T>(T data) async {
    await Future.delayed(MockConfig.effectiveDelay);

    if (MockConfig.isErrorForced) {
      return const Left(MockConfig.errorMessage);
    }

    return Right(data);
  }

  /// نسخة لليستات — بتحترم الفاضي كمان.
  static Future<Either<String, List<T>>> fetchList<T>(List<T> data) async {
    await Future.delayed(MockConfig.effectiveDelay);

    if (MockConfig.isErrorForced) {
      return const Left(MockConfig.errorMessage);
    }

    if (MockConfig.isEmptyForced) {
      return const Right(<Never>[]);
    }

    return Right(data);
  }

  /// نسخة مرقّمة — **بتقلّد `LengthAwarePaginator` بتاع لارافيل**.
  ///
  /// بتاخد القايمة كاملة وبتقصّها، لأن الـ mock عنده كل حاجة في الذاكرة.
  /// يوم الربط الطلب بياخد `page`/`per_page` والسيرفر هو اللي بيقصّ —
  /// والـ cubit مابيفرقش، هو بيقرا [PaginatedUiModel] في الحالتين. عدم
  /// التماثل ده بالظبط هو اللي الكلاس ده موجود عشان يمتصّه.
  ///
  /// ⚠ **القص هنا مش في `MockBookings`.** ده حساب paginator مش معرفة
  /// حجوزات — ولو اتكرر في كل fixture، أول واحدة تغلط في الحدود هتغلط
  /// لوحدها ومحدش هيلاحظ.
  static Future<Either<String, PaginatedUiModel<T>>> fetchPage<T>(
    List<T> all, {
    required int page,
    required int perPage,
  }) async {
    await Future.delayed(MockConfig.effectiveDelay);

    if (MockConfig.isErrorForced) {
      return const Left(MockConfig.errorMessage);
    }

    if (MockConfig.isEmptyForced) {
      return Right(_emptyPage<T>(perPage));
    }

    final total = all.length;
    final start = ((page - 1) * perPage).clamp(0, total);
    final end = (start + perPage).clamp(0, total);

    return Right(
      PaginatedUiModel<T>(
        data: all.sublist(start, end),
        currentPage: page,
        lastPage: _lastPage(total: total, perPage: perPage),
        perPage: perPage,
        total: total,
      ),
    );
  }

  /// ⚠ **صفحة واحدة على الأقل حتى لو مفيش ولا عنصر.**
  ///
  /// `max(ceil(total / perPage), 1)` — ده اللي لارافيل بيعمله بالظبط.
  /// صفر صفحات مالهاش معنى: العميل واقف على صفحة ١ بيبصّ على قايمة فاضية.
  static int _lastPage({required int total, required int perPage}) {
    if (perPage <= 0) return 1;
    final pages = (total / perPage).ceil();
    return pages < 1 ? 1 : pages;
  }

  static PaginatedUiModel<T> _emptyPage<T>(int perPage) => PaginatedUiModel<T>(
    data: <T>[],
    currentPage: 1,
    lastPage: 1,
    perPage: perPage,
    total: 0,
  );
}
