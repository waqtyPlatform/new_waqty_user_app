import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_in_branch.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/features/booking/in_branch/logic/in_branch_state.dart';

/// حالة العميل جوه الفرع لحجز واحد.
///
/// وريث `BranchQueueCubit` — **الشكل اتحافظ عليه والمحتوى اتغيّر**. الكود
/// القديم كان مكتوب صح في تلات حاجات بتخالف نمط الـ cubits الحالي، وكلها
/// كانت عن قصد ومنقولة هنا زي ما هي:
///
/// **١. مسار تحديث صامت.** باقي الـ cubits بتعمل `emit(LoadingState())` مع
/// كل تحميل. لو عملنا كده كل ٢٠ ثانية، الشاشة هتومض ومكان السكرول هيضيع.
/// [_tick] بيـ emit حالة الداتا على طول من غير ما يعدّي على التحميل —
/// أول تحميل بس هو اللي بيوري السكيلتون.
///
/// **٢. `close()` بيلغي المؤقت.** من غير الإلغاء بيفضل ينبض بعد ما الشاشة
/// تقفل ويرمي على cubit مقفول.
///
/// **٣. `AppLifecycleListener`.** لما الأبلكيشن يروح ورا، النبض بيقف —
/// من غير كده بنستهلك بطارية على شاشة محدش شايفها. الـ listener ده
/// **مش محتاج `StatefulWidget`**، فقاعدة «الحالة في الـ Cubit» محفوظة.
class InBranchCubit extends Cubit<InBranchState> {
  /// كل قد إيه بنسأل. ٢٠ ثانية كفاية لدور بيتحرّك كل ٣٥ دقيقة، وقليلة
  /// كفاية إن العميل مايحسّش إن الرقم بايت.
  static const Duration _pollEvery = Duration(seconds: 20);

  final BookingUiModel booking;

  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  /// آخر حالة اتبلّغ عنها — عشان منطلّعش نفس التنبيه مرتين.
  BookingStatus? _lastNotified;

  InBranchCubit({required this.booking}) : super(const InBranchInitialState());

  static InBranchCubit get(BuildContext context) =>
      BlocProvider.of<InBranchCubit>(context);

  /// الداتا اللي لسه بتتعرض، أو `null` قبل أول تحميل / لما مفيش حاجة.
  InBranchUiModel? get data =>
      state is InBranchReadyState ? (state as InBranchReadyState).data : null;

  /// بيتنادى مرة واحدة عند الإنشاء.
  void start() {
    emit(const InBranchLoadingState());
    _tick();

    _timer = Timer.periodic(_pollEvery, (_) => _tick());

    _lifecycle = AppLifecycleListener(
      onResume: () {
        // أول ما يرجع، حدّث فورًا — اللي على الشاشة بقى بايت.
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

    // TODO(api): الحالة بتيجي من `GET /api/user/bookings/{uuid}` — الحقل
    //   `status` موجود فعلاً. اللي مش موجود هو **التقدير الزمني**، وده
    //   السبب إن `MockInBranch` هيفضل موجود بعد الربط لحد ما السيرفر
    //   يوفّر إشارة.
    final next = MockInBranch.forBooking(booking, DateTime.now());

    emit(next == null ? const InBranchIdleState() : InBranchReadyState(next));
  }

  /// بيرجّع `true` مرة واحدة بس لكل انتقال يستاهل تنبيه.
  ///
  /// **ده بديل الـ push.** مفيش transport في المنظومة كلها — التوكنات
  /// بتتخزن في `app_device_tokens` ومحدش بيقراها، ومفيش package ولا
  /// listener ولا sender. فالأبلكيشن بيحاكي **اللحظة** عشان نعرف لو
  /// التلات رسايل دول هما الصح، حتى لو مقدرش يبعتها.
  ///
  /// الـ widget هو اللي بيعرض التنبيه — الـ Cubit مابيعرفش عن `context`
  /// ولا عن الـ toasts. هو بس بيقول «الانتقال ده جديد».
  bool shouldAnnounce(InBranchUiModel current) {
    if (!current.needsAttention) return false;
    if (_lastNotified == current.status) return false;
    _lastNotified = current.status;
    return true;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _lifecycle?.dispose();
    return super.close();
  }
}
