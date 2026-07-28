import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/splash/logic/splash_state.dart';

/// بيقرر العميل يفتح على إيه.
///
/// قبل كده `main.dart` كان بيفتح على شاشة التسجيل **دايمًا** — حتى للي عامل
/// لوجين إمبارح. كان في كود بيتشيك على التوكن فعلًا، بس نتيجته مكانتش
/// بتتقري خالص.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(InitialState());

  Future<void> checkSession() async {
    emit(SplashLoadingState());

    // شوية وقت عشان اللوجو يبان، من غير ما نأخّر العميل.
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final token = await CacheHelper.getSecuredString(
        ConstantKeys.saveTokenToShared,
      );
      final hasToken = token != null && token.toString().isNotEmpty;
      emit(hasToken ? GoToHomeState() : GoToLoginState());
    } catch (_) {
      // لو التخزين الآمن ضرب لأي سبب، منوقعش الأبلكيشن — نوديه للوجين.
      emit(GoToLoginState());
    }
  }

  static SplashCubit get(context) => BlocProvider.of(context);
}
