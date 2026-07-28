import 'package:waqty_user_application/core/models/queue_ui_model.dart';

sealed class BranchQueueState {
  const BranchQueueState();
}

class BranchQueueInitialState extends BranchQueueState {
  const BranchQueueInitialState();
}

/// **أول تحميل بس.** النبض بعد كده مابيعملش الحالة دي.
class BranchQueueLoadingState extends BranchQueueState {
  const BranchQueueLoadingState();
}

/// حالة شايلة داتا.
///
/// باقي الـ cubits في الأبلكيشن بتحط الداتا في حقل عادي وبتـ emit كلاس
/// علامة فاضي. هنا الداتا **جوه الحالة** عن قصد: النبض بيحصل كل ٢٠ ثانية،
/// والحالة العلامة مابتقولش لـ `BlocBuilder` إن فيه حاجة اتغيّرت لو الحقل
/// اتعدّل بس. وكمان بيخلي `previous != current` مقارنة حقيقية.
class BranchQueueReadyState extends BranchQueueState {
  final QueueUiModel queue;

  const BranchQueueReadyState(this.queue);

  @override
  bool operator ==(Object other) =>
      other is BranchQueueReadyState &&
      other.queue.myPosition == queue.myPosition &&
      other.queue.nowServing == queue.nowServing &&
      other.queue.state == queue.state &&
      other.queue.updatedAt == queue.updatedAt;

  @override
  int get hashCode => Object.hash(
    queue.myPosition,
    queue.nowServing,
    queue.state,
    queue.updatedAt,
  );
}

class BranchQueueErrorState extends BranchQueueState {
  final String message;

  const BranchQueueErrorState(this.message);
}
