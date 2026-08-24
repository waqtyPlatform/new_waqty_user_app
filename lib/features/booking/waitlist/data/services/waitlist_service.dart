import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';

abstract class WaitlistService {
  /// ⚠ **مش مقسّم صفحات** — `UserWaitlistController::index` بيرجّع مجموعة
  /// عادية. طلبات قايمة الانتظار قليلة بطبيعتها.
  Future<Either<Failure, List<WaitlistUiModel>>> list();

  /// خروج من القايمة.
  Future<Either<Failure, Unit>> cancel(String uuid);

  /// قبول العرض — بيحوّله لحجز حقيقي.
  ///
  /// [offerUuid] اختياري: لو فاضي، السيرفر بياخد العرض الشغّال.
  Future<Either<Failure, Unit>> accept({
    required String uuid,
    String? offerUuid,
  });

  /// **النوتة و`offer_uuid` الاتنين مطلوبين** في `request-change`.
  ///
  /// ومنطقي: الفرع لو ماعرفش إيه المشكلة هيبعت نفس النوع من العروض تاني،
  /// والمحاولات معدودة.
  Future<Either<Failure, Unit>> requestChange({
    required String uuid,
    required String offerUuid,
    required String note,
  });

  /// رسالة في خيط الطلب — حد ٢٠٠٠ حرف.
  Future<Either<Failure, Unit>> sendMessage({
    required String uuid,
    required String body,
  });
}
