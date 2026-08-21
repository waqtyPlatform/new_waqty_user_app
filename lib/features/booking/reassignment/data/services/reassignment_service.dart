import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';

/// عقد إعادة توزيع الحجز — ٦ endpoints، كلهم موجودين وشغالين.
abstract class ReassignmentService {
  Future<Either<Failure, List<ReassignmentUiModel>>> list();

  Future<Either<Failure, ReassignmentUiModel>> detail(String uuid);

  /// رسالة للفرع في محادثة الطلب.
  Future<Either<Failure, Unit>> sendMessage({
    required String uuid,
    required String body,
  });

  /// قبول الاقتراح — **الحجز بيتنقل فعلاً**.
  ///
  /// ⚠ ممكن يفشل لو المهلة خلصت والميعاد راح لحد تاني. الخدمة بترجّع
  /// الفشل زي ما هو والشاشة بتعيد القراءة.
  Future<Either<Failure, Unit>> acceptProposal(String proposalUuid);

  /// **النوتة مطلوبة** — `request-change` بيرفض من غيرها.
  Future<Either<Failure, Unit>> requestChange({
    required String proposalUuid,
    required String note,
  });

  /// إلغاء الاقتراح — **بيلغي الحجز كله** بسبب
  /// `customer_declined_reassignment`، مش بيرجّعه للميعاد القديم.
  Future<Either<Failure, Unit>> cancelProposal(String proposalUuid);
}
