import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/apple_login_service.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/services/google_login_service.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/features/account/account/logic/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(AccountInitialState());

  bool isGuest = true;

  Future<void> loadAccountState() async {
    emit(AccountLoadingState());
    final token = await CacheHelper.getSecuredString(
      ConstantKeys.saveTokenToShared,
    );
    isGuest = token.isEmpty;
    emit(AccountLoadedState(isGuest: isGuest));
  }

  Future<void> logout() async {
    emit(AccountLogoutLoadingState());
    await CacheHelper.removeSecureData(ConstantKeys.saveTokenToShared);
    try {
      await getIt<GoogleLoginService>().resetSession();
    } catch (_) {}
    try {
      await getIt<AppleLoginService>().signOut();
    } catch (_) {}
    emit(AccountLogoutSuccessState());
  }

  static AccountCubit get(context) => BlocProvider.of(context);
}
