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

    _lifecycle = AppLifecycleListener(
      onResume: load,
      onPause: _stopTimer,
    );

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
  /// TODO(api): DELETE /api/user/waitlist/{uuid}
  ///
  /// ⚠ **الـ endpoint ده مش موجود.** `load` و`joinWaitlist` بيشاوروا على
  /// راوتس مبنية فعلاً (`routes/api.php:642-645`)، ودي **طلب للباك إند**
  /// لسه ما اتعملش. لحد ما يتعمل، الشيل محلي بس — والعميل اللي خرج من
  /// القائمة وقفل الأبلكيشن هيلاقي نفسه فيها تاني.
  ///
  /// الزرار موجود عشان ده **الفعل الوحيد** اللي الميزة بتديه للعميل: هو
  /// مايقدرش يقبل عرض بنفسه (`accept` تحت `/provider/`)، فلو شيلنا
  /// الخروج كمان بتبقى حاجة بتتعمل **عليه** مش معاه.
  void removeEntry(String uuid) => MockWaitlist.removeByUuid(uuid);

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
