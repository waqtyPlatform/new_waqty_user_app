import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';

sealed class WaitlistState {
  const WaitlistState();
}

class WaitlistInitialState extends WaitlistState {
  const WaitlistInitialState();
}

class WaitlistLoadingState extends WaitlistState {
  const WaitlistLoadingState();
}

/// مفيش إدخالات — القسم كله بيختفي.
class WaitlistEmptyState extends WaitlistState {
  const WaitlistEmptyState();
}

class WaitlistReadyState extends WaitlistState {
  final List<WaitlistUiModel> entries;

  /// بيتغيّر كل ثانية وقت العدّ التنازلي — ده اللي بيخلي الـ `==`
  /// تحت تسمح بإعادة البناء وهو شغّال بس.
  final int tick;

  const WaitlistReadyState(this.entries, {this.tick = 0});

  /// **بنعيد البناء لما فيه عدّاد بس.**
  ///
  /// النبضة كل ثانية، ومن غير المقارنة دي القايمة كانت هتتبني من الأول
  /// كل ثانية حتى وهي ساكنة تمامًا.
  @override
  bool operator ==(Object other) =>
      other is WaitlistReadyState &&
      other.tick == tick &&
      other.entries.length == entries.length;

  @override
  int get hashCode => Object.hash(tick, entries.length);
}
