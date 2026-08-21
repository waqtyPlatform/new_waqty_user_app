import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/api/session_store.dart';
import 'package:waqty_user_application/core/models/app_gate_ui_model.dart';
import 'package:waqty_user_application/features/splash/data/repo/app_gate_repo.dart';
import 'package:waqty_user_application/features/splash/logic/splash_state.dart';

/// بيقرر العميل يفتح على إيه.
///
/// قبل كده `main.dart` كان بيفتح على شاشة التسجيل **دايمًا** — حتى للي عامل
/// لوجين إمبارح. كان في كود بيتشيك على التوكن فعلًا، بس نتيجته مكانتش
/// بتتقري خالص.
class SplashCubit extends Cubit<SplashState> {
  final AppGateRepo _gateRepo;
  final SessionStore _session;

  SplashCubit(this._gateRepo, this._session) : super(InitialState());

  /// البوابة اللي وقّفت الأبلكيشن — الشاشة بتقراها عشان تعرض الحوار.
  AppGateUiModel? gate;

  Future<void> checkSession() async {
    emit(SplashLoadingState());

    // ⚠ **البوابة قبل فحص الجلسة.**
    //
    // صيانة أو تحديث إجباري معناهم إن الأبلكيشن مايكملش أصلاً،
    // فجيب توكن وتحميل رئيسية شغل ضايع. والنداء ده **مفتوح** (مش
    // محتاج توكن) فمفيش اعتماد على الجلسة.
    //
    // والفشل في النداء بيرجّع بوابة مفتوحة — شوف `AppGateRepo.evaluate`.
    final gateResult = await _gateRepo.evaluate();
    if (isClosed) return;

    if (gateResult.isBlocking) {
      gate = gateResult;
      emit(AppGateBlockedState(gate: gateResult));
      return;
    }

    // شوية وقت عشان اللوجو يبان، من غير ما نأخّر العميل.
    //
    // نداء البوابة فوق بياخد وقت برضه، فالتأخير هنا بقى أقصر.
    await Future.delayed(const Duration(milliseconds: 200));
    if (isClosed) return;

    emit(_session.hasToken ? GoToHomeState() : GoToLoginState());
  }

  static SplashCubit get(context) => BlocProvider.of(context);
}
