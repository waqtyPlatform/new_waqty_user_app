import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';

sealed class ReassignmentState {
  const ReassignmentState();
}

class ReassignmentInitialState extends ReassignmentState {
  const ReassignmentInitialState();
}

class ReassignmentLoadingState extends ReassignmentState {
  const ReassignmentLoadingState();
}

/// مفيش أي طلب إعادة توزيع — **الحالة الغالبة والمطلوبة**.
///
/// إعادة التوزيع بتحصل لما موظف يخرج إجازة. العميل الطبيعي مايشوفهاش أبدًا،
/// فالشاشة دي مابتتفتحش من التبويبات — بتتفتح من إشعار أو من كارت على
/// تفاصيل الحجز.
class ReassignmentEmptyState extends ReassignmentState {
  const ReassignmentEmptyState();
}

class ReassignmentReadyState extends ReassignmentState {
  final List<ReassignmentUiModel> entries;

  /// **بيتغيّر كل ثانية والمهلة شغّالة.**
  ///
  /// من غيره `Equatable` (أو أي مقارنة) بتشوف نفس الحالة فالـ`BlocBuilder`
  /// مابيعيدش البناء والعدّاد بيتجمّد على رقمه.
  final int tick;

  const ReassignmentReadyState(this.entries, {this.tick = 0});
}

class ReassignmentErrorState extends ReassignmentState {
  final String message;

  const ReassignmentErrorState({required this.message});
}

/// بيتبعت فعل (قبول · طلب تغيير · إلغاء · رسالة) — الزراير بتتقفل.
class ReassignmentActionLoadingState extends ReassignmentState {
  const ReassignmentActionLoadingState();
}

/// الاقتراح اتقبل والحجز اتنقل — الشاشة بتقفل وترجع للحجوزات.
class ReassignmentAcceptedState extends ReassignmentState {
  const ReassignmentAcceptedState();
}

/// **الحجز اتلغى بالكامل.**
///
/// ⚠ الإلغاء هنا مش رفض للاقتراح وبس — السيرفر بيلغي الحجز الأصلي بسبب
/// `customer_declined_reassignment`. الشاشة لازم تقول ده صريح قبل التأكيد.
class ReassignmentCancelledState extends ReassignmentState {
  const ReassignmentCancelledState();
}

/// الفعل فشل — الرسالة بتتعرض من غير ما الشاشة تتفضّى.
class ReassignmentActionFailedState extends ReassignmentState {
  final String message;

  const ReassignmentActionFailedState({required this.message});
}
