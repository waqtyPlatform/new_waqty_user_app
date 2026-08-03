import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_account.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/account/account/logic/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(InitialState());

  AccountUiModel? account;

  Future<void> getProfile() async {
    emit(AccountLoadingState());

    // TODO(api): GET /api/user/auth/me
    final result = await MockSource.fetch(MockAccount.me);

    result.fold((failure) => emit(AccountErrorState(message: failure)), (data) {
      account = data;
      emit(AccountSuccessState());
    });
  }

  /// تسجيل الخروج — **مكانش موجود في الأبلكيشن خالص**.
  ///
  /// يعني اللي بيسجّل دخول مرة، مفيش طريقة يخرج بيها. لو حد فتح
  /// حسابه على موبايل صاحبه أو على جهاز في المحل، مش هيعرف يقفله.
  Future<void> logout() async {
    emit(LogoutLoadingState());

    // TODO(api): POST /api/user/auth/logout
    await Future.delayed(const Duration(milliseconds: 500));

    await CacheHelper.removeSecureData(ConstantKeys.saveTokenToShared);
    emit(LogoutSuccessState());
  }

  static AccountCubit get(context) => BlocProvider.of(context);
}
