import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_queue.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/queue_ui_model.dart';
import 'package:waqty_user_application/features/booking/branch_queue/logic/branch_queue_state.dart';

/// حالة الدور الحية لحجز واحد.
///
/// ## تلات حاجات بتخالف نمط الـ cubits الحالي — كلها عن قصد
///
/// **١. مسار تحديث صامت.** باقي الـ cubits بتعمل `emit(LoadingState())` مع
/// كل تحميل. لو عملنا كده كل ٢٠ ثانية، الشاشة هتومض ومكان السكرول هيضيع.
/// [_tick] بيـ emit حالة الداتا على طول من غير ما يعدّي على التحميل —
/// أول تحميل بس هو اللي بيوري السكيلتون.
///
/// **٢. `close()` بيلغي المؤقت.** مفيش ولا `close()` في السبع cubits
/// الحاليين لأن مفيش فيهم حاجة بتعيش بعد الشاشة. ده عنده مؤقت، ومن غير
/// الإلغاء بيفضل ينبض بعد ما الشاشة تقفل ويرمي على cubit مقفول.
///
/// **٣. `AppLifecycleListener`.** لما الأبلكيشن يروح ورا، النبض بيقف —
/// من غير كده بنستهلك بطارية على شاشة محدش شايفها. الـ listener ده
/// **مش محتاج `StatefulWidget`** (فلاتر 3.13+)، فقاعدة «الحالة في الـ
/// Cubit» محفوظة.
class BranchQueueCubit extends Cubit<BranchQueueState> {
  /// كل قد إيه بنسأل. ٢٠ ثانية كفاية لطابور بيتحرّك كل ٣٥ دقيقة، وقليلة
  /// كفاية إن العميل مايحسّش إن الرقم بايت.
  static const Duration _pollEvery = Duration(seconds: 20);

  final BookingUiModel booking;

  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  /// آخر حالة اتبلّغ عنها — عشان منطلّعش نفس التنبيه مرتين.
  QueueState? _lastNotified;

  BranchQueueCubit({required this.booking})
    : super(const BranchQueueInitialState());

  static BranchQueueCubit get(BuildContext context) =>
      BlocProvider.of<BranchQueueCubit>(context);

  /// الحالة اللي لسه بتتعرض، أو `null` قبل أول تحميل.
  QueueUiModel? get queue =>
      state is BranchQueueReadyState ? (state as BranchQueueReadyState).queue : null;

  /// بيتنادى مرة واحدة عند الإنشاء.
  void start() {
    emit(const BranchQueueLoadingState());
    _tick();

    _timer = Timer.periodic(_pollEvery, (_) => _tick());

    _lifecycle = AppLifecycleListener(
      onResume: () {
        // أول ما يرجع، حدّث فورًا — الرقم اللي على الشاشة بقى بايت.
        _tick();
        _timer ??= Timer.periodic(_pollEvery, (_) => _tick());
      },
      onPause: () {
        _timer?.cancel();
        _timer = null;
      },
    );
  }

  /// تحديث **صامت** — مفيش `LoadingState`.
  void _tick() {
    if (isClosed) return;

    // TODO(api): GET /api/user/bookings/{uuid}/queue
    final next = MockQueue.forBooking(booking, DateTime.now());

    emit(BranchQueueReadyState(next));
  }

  /// بيرجّع `true` مرة واحدة بس لكل انتقال يستاهل تنبيه.
  ///
  /// الـ widget هو اللي بيعرض التنبيه — الـ Cubit مابيعرفش عن `context`
  /// ولا عن الـ toasts. هو بس بيقول «الانتقال ده جديد».
  bool shouldAnnounce(QueueState current) {
    if (!current.needsAttention) return false;
    if (_lastNotified == current) return false;
    _lastNotified = current;
    return true;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _lifecycle?.dispose();
    return super.close();
  }
}
