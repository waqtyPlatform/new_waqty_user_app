import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';

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
}
