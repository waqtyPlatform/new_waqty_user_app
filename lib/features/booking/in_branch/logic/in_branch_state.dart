import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';

sealed class InBranchState {
  const InBranchState();
}

class InBranchInitialState extends InBranchState {
  const InBranchInitialState();
}

class InBranchLoadingState extends InBranchState {
  const InBranchLoadingState();
}

/// الحجز مش في الفرع دلوقتي — مفيش حاجة تتعرض.
///
/// حالة لوحدها مش `null` جوه [InBranchReadyState]: الشاشات بتقرر تخفي
/// السطح كله من الحالة دي، والفرق بين «مفيش حاجة» و«لسه بيحمّل» لازم
/// يفضل باين.
class InBranchIdleState extends InBranchState {
  const InBranchIdleState();
}

class InBranchReadyState extends InBranchState {
  final InBranchUiModel data;

  const InBranchReadyState(this.data);

  /// **مقارنة بالقيمة عشان النبض ما يعيدش البناء على الفاضي.**
  ///
  /// الـ cubit بينبض كل ٢٠ ثانية. من غير الـ `==` دي، كل نبضة بتعمل
  /// `emit` بكائن جديد والشاشة بتتبني من الأول حتى لو ولا رقم اتغيّر.
  @override
  bool operator ==(Object other) =>
      other is InBranchReadyState &&
      other.data.status == data.status &&
      other.data.employeeName == data.employeeName &&
      other.data.estimateLow == data.estimateLow &&
      other.data.estimateHigh == data.estimateHigh;

  @override
  int get hashCode => Object.hash(
    data.status,
    data.employeeName,
    data.estimateLow,
    data.estimateHigh,
  );
}
