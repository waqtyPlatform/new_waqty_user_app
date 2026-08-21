import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/reassignment_ui_model.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/repo/reassignment_repo.dart';
import 'package:waqty_user_application/features/booking/reassignment/logic/reassignment_state.dart';

/// حالة طلبات إعادة توزيع الحجز.
///
/// ## المؤقت — منسوخ من `WaitlistCubit` بقصد
///
/// نفس المعمارية بالحرف: `Timer.periodic` ثانية **بيشتغل بس والمهلة
/// شغّالة**، `AppLifecycleListener` بيوقّفه لما الأبلكيشن يروح الخلفية،
/// حراسة `isClosed` على كل `emit`، وإلغاء في `close()`. الشكل ده مدفوع
/// تمنه في قايمة الانتظار، ومفيش سبب نخترع غيره.
///
/// الفرق الوحيد: **المهلة هنا ١٥ دقيقة مش ٥**.
///
/// ⚠ **العدّاد بيتحسب من `hold_expires_at` (لحظة مطلقة) مش من
/// `hold_remaining_seconds` (لقطة).** الأبلكيشن بيروح الخلفية وبيرجع؛
/// اللقطة بتبقى بايتة والعميل يشوف «فاضل ١٤ دقيقة» وهي خلصت من زمان.
///
/// ## ⚠ مفيش إشعارات
///
/// `BookingReassignmentLifecycleEvent` بيتبعت في الباك-إند بفلاجات
/// `notifyCustomer` بس **مفيش أي listener مسجّل** — يعني مفيش push. العميل
/// بيعرف بالاقتراح لما يفتح الأبلكيشن وبس، ومهلة ١٥ دقيقة العميل يعرف بيها
/// بالصدفة مش مهلة.
///
/// التعويض هنا: [start] بتعيد القراءة عند كل رجوع من الخلفية، والشاشات
/// التانية بتعرض بانر لما يبقى فيه طلب مفتوح. ده بيقلّل الضرر مش بيشيله.
class ReassignmentCubit extends Cubit<ReassignmentState> {
  final ReassignmentRepo _repo;

  ReassignmentCubit(this._repo) : super(const ReassignmentInitialState());

  static ReassignmentCubit get(BuildContext context) =>
      BlocProvider.of<ReassignmentCubit>(context);

  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  int _tick = 0;

  List<ReassignmentUiModel> entries = <ReassignmentUiModel>[];

  /// فيه طلب مستني رد العميل؟ — مصدر الشارة والبانر.
  bool get hasOpenRequest =>
      entries.any((e) => e.needsMyAnswer && e.isHoldActive(DateTime.now()));

  ReassignmentUiModel? byUuid(String uuid) {
    final matches = entries.where((e) => e.uuid == uuid);
    return matches.isEmpty ? null : matches.first;
  }

  void start() {
    emit(const ReassignmentLoadingState());
    load();

    // ⚠ الرجوع من الخلفية **بيعيد القراءة** — ده تعويض غياب الـpush.
    _lifecycle = AppLifecycleListener(onResume: load, onPause: _stopTimer);
  }

  Future<void> load() async {
    if (isClosed) return;

    final result = await _repo.list();
    if (isClosed) return;

    result.fold(
      (failure) {
        _stopTimer();
        emit(ReassignmentErrorState(message: failure.message));
      },
      (data) {
        entries = data;

        if (entries.isEmpty) {
          _stopTimer();
          emit(const ReassignmentEmptyState());
          return;
        }

        _syncTimer();
        emit(ReassignmentReadyState(entries, tick: _tick));
      },
    );
  }

  Future<void> acceptProposal(String proposalUuid) =>
      _act(() => _repo.acceptProposal(proposalUuid), const ReassignmentAcceptedState());

  Future<void> requestChange({
    required String proposalUuid,
    required String note,
  }) => _act(
    () => _repo.requestChange(proposalUuid: proposalUuid, note: note),
    null,
  );

  Future<void> cancelProposal(String proposalUuid) => _act(
    () => _repo.cancelProposal(proposalUuid),
    const ReassignmentCancelledState(),
  );

  Future<void> sendMessage({required String uuid, required String body}) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return Future<void>.value();

    return _act(() => _repo.sendMessage(uuid: uuid, body: trimmed), null);
  }

  /// **كل فعل بيمشي على نفس المسار:** قفل الزراير → نداء → إعادة قراءة.
  ///
  /// إعادة القراءة مش رفاهية: `accept` ممكن يفشل لو المهلة خلصت والميعاد
  /// راح، و`request-change` بيزوّد `attempts`. الشاشة لازم تعرض حالة
  /// السيرفر مش اللي إحنا فاكرينه.
  Future<void> _act(
    Future<dynamic> Function() call,
    ReassignmentState? successState,
  ) async {
    emit(const ReassignmentActionLoadingState());

    final result = await call();
    if (isClosed) return;

    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(ReassignmentActionFailedState(message: failure.message));
      // بنعيد القراءة برضه: أشهر سبب للفشل إن المهلة خلصت، والشاشة لازم
      // توري الحالة الجديدة مش تفضل على القديمة.
      await load();
      return;
    }

    if (successState != null) {
      emit(successState);
      return;
    }

    await load();
  }

  void _syncTimer() {
    final needsTicking = entries.any((e) => e.isHoldActive(DateTime.now()));

    if (!needsTicking) {
      _stopTimer();
      return;
    }

    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      _tick++;

      // العدّاد وصل صفر؟ نعيد القراءة عشان الحالة تتحوّل — نفس الـ lazy
      // expiry اللي السيرفر بيعمله في `expireDue()`.
      if (!entries.any((e) => e.isHoldActive(DateTime.now()))) {
        load();
        return;
      }

      emit(ReassignmentReadyState(entries, tick: _tick));
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
