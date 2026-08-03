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

  /// TODO(api): POST /user/waitlist
  ///
  /// الـ body: `{branch_uuid, service_uuid, employee_uuid?,
  /// preferred_date, preferred_time, notes?}` — زي
  /// `UserWaitlistController::store` بالظبط.
  void addEntry({
    required String providerName,
    required String branchName,
    required String serviceName,
    required DateTime preferredAt,
    String? employeeName,
  }) {
    MockWaitlist.add(
      providerName: providerName,
      branchName: branchName,
      serviceName: serviceName,
      preferredAt: preferredAt,
      employeeName: employeeName,
    );
    load();
  }

  void removeEntry(String uuid) {
    MockWaitlist.removeByUuid(uuid);
    load();
  }

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
    _stopTimer();
    _lifecycle?.dispose();
    return super.close();
  }
}
