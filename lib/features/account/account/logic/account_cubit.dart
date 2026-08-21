import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/api/session_store.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';
import 'package:waqty_user_application/features/account/account/data/repo/account_repo.dart';
import 'package:waqty_user_application/features/account/account/logic/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AccountRepo _repo;
  final SessionStore _session;

  AccountCubit(this._repo, this._session) : super(InitialState());

  AccountUiModel? account;

  Future<void> getProfile() async {
    emit(AccountLoadingState());

    final result = await _repo.profile();
    if (isClosed) return;

    result.fold(
      (failure) => emit(AccountErrorState(message: failure.message)),
      (data) {
        account = data;
        emit(AccountSuccessState());
      },
    );
  }

  /// تسجيل الخروج — **مكانش موجود في الأبلكيشن خالص**.
  ///
  /// يعني اللي بيسجّل دخول مرة، مفيش طريقة يخرج بيها. لو حد فتح حسابه على
  /// موبايل صاحبه أو على جهاز في المحل، مش هيعرف يقفله.
  Future<void> logout() async {
    emit(LogoutLoadingState());

    // ⚠ **النداء الأول والمسح بعده — والمسح بيحصل مهما كان الرد.**
    //
    // لو السيرفر مردّش (نت مقطوع مثلاً) والعميل داس خروج، المفروض يخرج
    // برضه. الجلسة اللي بتفضل شغّالة لأن نداء فشل أوحش من توكن مابطّلش
    // على السيرفر.
    await _repo.logout();

    // ⚠ **`SessionStore.clear()` مش `CacheHelper` لوحده.**
    //
    // التوكن عايش في مكانين: المخزن الآمن، ونسخة ساخنة في الذاكرة بيقرا
    // منها الـinterceptor. مسح المخزن بس بيسيب النسخة الساخنة شغّالة —
    // يعني العميل «خرج» والطلبات لسه بتتبعت باسمه لحد ما الأبلكيشن يتقفل.
    // دي كانت ثغرة حقيقية.
    await _session.clear();

    if (isClosed) return;
    emit(LogoutSuccessState());
  }

  static AccountCubit get(context) => BlocProvider.of(context);
}
