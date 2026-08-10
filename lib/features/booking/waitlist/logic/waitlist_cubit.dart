import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_waitlist.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/features/booking/waitlist/logic/waitlist_state.dart';

/// إدخالات العميل في قوائم الانتظار.
///
/// ## المؤقت بينبض كل **ثانية** مش كل ٢٠
///
/// الحجز المؤقت ٥ دقايق وبيتعرض كعدّاد `٤:٣٢`. عدّاد بينط ٢٠ ثانية مرة
/// واحدة بيتقرا معطّل. النبض بيقف لوحده أول ما مفيش عرض شغّال — يعني
/// في الحالة الغالبة (`pending` بس) مفيش مؤقت أصلاً.
class WaitlistCubit extends Cubit<WaitlistState> {
  WaitlistCubit() : super(const WaitlistInitialState());

  static WaitlistCubit get(BuildContext context) =>
      BlocProvider.of<WaitlistCubit>(context);

  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  int _tick = 0;

  List<WaitlistUiModel> entries = <WaitlistUiModel>[];

  void start() {
    emit(const WaitlistLoadingState());
    load();

    _lifecycle = AppLifecycleListener(onResume: load, onPause: _stopTimer);

    // الانضمام بيحصل من **جوه sheet** ممكن تكون مدفوعة من شاشة مش تحت
    // الـ provider ده — فمافيش طريق مباشر ينده `load()`. الإشارة بتحل ده
    // من غير ما الـ sheet تعرف حاجة عن الشجرة. يوم الربط بتتشال ومحلها
    // إعادة القراءة بعد رد الـ `POST`.
    MockWaitlist.revision.addListener(load);
  }

  /// TODO(api): GET /user/waitlist
  void load() {
    if (isClosed) return;

    entries = MockWaitlist.forUser(DateTime.now());

    if (entries.isEmpty) {
      _stopTimer();
      emit(const WaitlistEmptyState());
      return;
    }

    _syncTimer();
    emit(WaitlistReadyState(entries, tick: _tick));
  }

  /// **الخروج من القائمة.**
  ///
  /// TODO(api): POST /api/user/waitlist/{uuid}/cancel
  ///
  /// ⚠ التعليق القديم هنا كان بيقول إن الـ endpoint ده **مش موجود** وإنه
  /// طلب للباك إند لسه ما اتعملش، وإن الشيل محلي بس. **الكلام ده بقى
  /// غلط**: waitlist v2 عمل الراوت، ومعاه `accept` و`request-change`.
  void leaveQueue(String uuid) {
    MockWaitlist.cancel(uuid);
    MockWaitlist.removeByUuid(uuid);
  }

  /// **العميل بيقبل العرض بنفسه.**
  ///
  /// TODO(api): POST /api/user/waitlist/{uuid}/accept
  ///
  /// ده أهم فعل اتضاف في v2. قبله كان `accept` تحت `/provider/` بس —
  /// يعني الموظف بيقبل نيابة عن العميل جوه مهلة العميل نفسه مش شايفها،
  /// والأبلكيشن كان بيعرض عدّاد من غير أي زرار جنبه.
  void acceptOffer(String uuid) => MockWaitlist.accept(uuid);

  /// **الميعاد المعروض مش مناسب — هات غيره.**
  ///
  /// TODO(api): POST /api/user/waitlist/{uuid}/request-change
  ///
  /// [note] **مطلوبة** في السيرفر. ومنطقي: الفرع لو ماعرفش إيه المشكلة
  /// هيبعت نفس النوع من العروض تاني، والمحاولات معدودة.
  void requestChange(String uuid, String note) =>
      MockWaitlist.requestChange(uuid, note);

  /// رسالة في خيط الطلب.
  ///
  /// TODO(api): POST /api/user/waitlist/{uuid}/conversation
  void sendMessage(String uuid, String body) =>
      MockWaitlist.sendMessage(uuid, body);

  /// المؤقت بيشتغل **بس** لما فيه حجز مؤقت شغّال.
  void _syncTimer() {
    final now = DateTime.now();
    final needsTicking = entries.any((e) => e.isHoldActive(now));

    if (!needsTicking) {
      _stopTimer();
      return;
    }

    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      _tick++;

      // العدّاد وصل صفر؟ نعيد القراءة عشان الحالة تتحوّل لـ `expired`
      // — نفس الـ lazy expiry اللي السيرفر بيعمله في `listForUser`.
      if (!entries.any((e) => e.isHoldActive(DateTime.now()))) {
        load();
        return;
      }

      emit(WaitlistReadyState(entries, tick: _tick));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    MockWaitlist.revision.removeListener(load);
    _stopTimer();
    _lifecycle?.dispose();
    return super.close();
  }
}
