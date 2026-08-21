import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/repo/waitlist_repo.dart';
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
  WaitlistCubit(this._repo) : super(const WaitlistInitialState());

  static WaitlistCubit get(BuildContext context) =>
      BlocProvider.of<WaitlistCubit>(context);

  final WaitlistRepo _repo;

  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  int _tick = 0;

  List<WaitlistUiModel> entries = <WaitlistUiModel>[];

  void start() {
    emit(const WaitlistLoadingState());
    load();

    // ⚠ الرجوع من الخلفية بيعيد القراءة — تعويض غياب الـpush. العرض
    // بمهلة ٥ دقايق، والعميل مايوصلوش إشعار لما ييجي.
    _lifecycle = AppLifecycleListener(onResume: load, onPause: _stopTimer);
  }

  /// ⚠ **الإشارة القديمة (`MockWaitlist.revision`) اتشالت.**
  ///
  /// كانت حيلة عشان الانضمام بيحصل من جوّه sheet مدفوعة من شاشة مش تحت
  /// الـprovider ده. دلوقتي الـsheet بتنده الـAPI بنفسها، والشاشة بتعيد
  /// القراءة عند الرجوع من الخلفية أو بعد أي فعل. الحيلة بقت مالهاش لزمة.
  ///
  /// اللي فاضل: انضمام من الويزارد وانت واقف على الرئيسية مش هيبان غير
  /// لما الرئيسية تتعمل ريفريش. مقبول — الشاشة بتقول «اتسجّلت» ساعتها.

  Future<void> load() async {
    if (isClosed) return;

    final result = await _repo.list();
    if (isClosed) return;

    result.fold(
      (failure) {
        _stopTimer();
        // ⚠ فشل القراءة **مش** حالة فاضية. «مفيش طلبات» و«مقدرناش نجيب
        // طلباتك» حاجتين مختلفتين تمامًا للعميل اللي مستني دوره.
        emit(WaitlistErrorState(message: failure.message));
      },
      (data) {
        entries = data;

        if (entries.isEmpty) {
          _stopTimer();
          emit(const WaitlistEmptyState());
          return;
        }

        _syncTimer();
        emit(WaitlistReadyState(entries, tick: _tick));
      },
    );
  }

  /// **الخروج من القائمة.**
  ///
  /// TODO(api): POST /api/user/waitlist/{uuid}/cancel
  ///
  /// ⚠ التعليق القديم هنا كان بيقول إن الـ endpoint ده **مش موجود** وإنه
  /// طلب للباك إند لسه ما اتعملش، وإن الشيل محلي بس. **الكلام ده بقى
  /// غلط**: waitlist v2 عمل الراوت، ومعاه `accept` و`request-change`.
  Future<void> leaveQueue(String uuid) async {
    await _repo.cancel(uuid);
    await load();
  }

  /// **العميل بيقبل العرض بنفسه.**
  ///
  /// TODO(api): POST /api/user/waitlist/{uuid}/accept
  ///
  /// ده أهم فعل اتضاف في v2. قبله كان `accept` تحت `/provider/` بس —
  /// يعني الموظف بيقبل نيابة عن العميل جوه مهلة العميل نفسه مش شايفها،
  /// والأبلكيشن كان بيعرض عدّاد من غير أي زرار جنبه.
  Future<void> acceptOffer(String uuid) async {
    // `offer_uuid` اختياري — السيرفر بياخد العرض الشغّال لو مابعتناش.
    await _repo.accept(uuid: uuid, offerUuid: byUuid(uuid)?.activeOfferUuid);
    await load();
  }

  WaitlistUiModel? byUuid(String uuid) {
    final matches = entries.where((e) => e.uuid == uuid);
    return matches.isEmpty ? null : matches.first;
  }

  /// **الميعاد المعروض مش مناسب — هات غيره.**
  ///
  /// TODO(api): POST /api/user/waitlist/{uuid}/request-change
  ///
  /// [note] **مطلوبة** في السيرفر. ومنطقي: الفرع لو ماعرفش إيه المشكلة
  /// هيبعت نفس النوع من العروض تاني، والمحاولات معدودة.
  Future<void> requestChange(String uuid, String note) async {
    // ⚠ **`offer_uuid` مطلوب** — من غيره ٤٢٢. لو مش موجود يبقى مفيش عرض
    // شغّال أصلاً، والفعل ده مالوش معنى.
    final offerUuid = byUuid(uuid)?.activeOfferUuid;
    if (offerUuid == null) return;

    await _repo.requestChange(uuid: uuid, offerUuid: offerUuid, note: note);
    await load();
  }

  /// رسالة في خيط الطلب.
  ///
  /// TODO(api): POST /api/user/waitlist/{uuid}/conversation
  Future<void> sendMessage(String uuid, String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    await _repo.sendMessage(uuid: uuid, body: trimmed);
    await load();
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
