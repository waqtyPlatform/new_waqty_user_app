import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_phone.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_request_model.dart';
import 'package:waqty_user_application/features/auth/login/data/models/login_response_model.dart';
import 'package:waqty_user_application/features/auth/login/data/repo/login_repo.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_state.dart';
import 'package:waqty_user_application/core/api/session_store.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  LoginCubit(this._loginRepo) : super(InitialState());

  GlobalKey<FormState> loginKey = GlobalKey();
  TextEditingController loginCountryCodeController = TextEditingController();
  TextEditingController loginPhoneController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  // `selectedFieldNumber` و`changeSelectedField` اتشالوا: كانوا بيلوّنوا
  // خلفية الحقل المركّز أخضر فاتح. التركيز بقى بيتقال بحد باللمسة من
  // `inputDecorationTheme`، فالحالة دي بقت بتعيد بناء حقلين مع كل ضغطة
  // من غير ما تغيّر حاجة على الشاشة.

  // **حالة إظهار كلمة السر اتشالت من هنا.**
  //
  // كانت `bool` + دالة + `State` في تلات cubits — تسع أعضاء كل
  // شغلهم يقلبوا أيقونة عين. `AppPasswordFieldWidget` بتاع الكيت
  // شايلها جواه، فضغطة العين بقت تبني الحقل بس بدل ما تبني الشاشة
  // كلها (٦ حقول في التسجيل).

  Future<void> login() async {
    emit(OnLoginLoadingState());
    final result = await _loginRepo
        .login(
          LoginRequestModel(
            // البوابة بترجّع الصيغة المحلية اللي الباك-إند بيقبلها.
            // لزق كود الدولة بالإيد كان بيطلّع `+2001113000000`.
            login: AppPhone.toApiFormat(loginPhoneController.text),
            password: loginPasswordController.text,
          ),
        )
        .catchError((error) {
          emit(OnLoginCatchErrorState());
        });

    result.fold(
      (failure) {
        emit(OnLoginErrorState(failure.message));
      },
      (loginResponse) async {
        if (loginResponse.data != null) {
          await cashUserData(loginResponse);
        }

        emit(OnLoginSuccessState(loginResponse));
      },
    );
  }

  /// ⚠ **عبر `SessionStore` مش `CacheHelper` مباشرة.**
  ///
  /// التوكن عايش في مكانين: المخزن الآمن، ونسخة ساخنة في الذاكرة
  /// `AppInterceptor` بيقرا منها (لأن قراية Keystore في كل طلب تقيلة).
  ///
  /// الكتابة في المخزن لوحده بتسيب النسخة الساخنة فاضية — فالطلبات
  /// بتخرج من غير هيدر مصادقة، وأول نداء محمي يرجّع ٤٠١، والأبلكيشن
  /// يرمي العميل على شاشة الدخول **بعد ما دخل بثانية**. ده حصل فعلاً
  /// واتمسك على المحاكي.
  ///
  /// `SessionStore.save` بيكتب في الاتنين وبيصفّر علامة الانتهاء.
  Future<void> cashUserData(LoginResponseModel response) async {
    await getIt<SessionStore>().save(response.data!.token);
  }

  static LoginCubit get(context) => BlocProvider.of(context);
}
