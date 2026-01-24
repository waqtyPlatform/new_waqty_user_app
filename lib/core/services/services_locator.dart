import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:get_it/get_it.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/repo/forget_password_repo.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/services/forget_password_service.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/repo/forget_verify_code_repo.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/services/forget_verify_code_service.dart';
import 'package:waqty_user_application/features/auth/login/data/repo/login_repo.dart';
import 'package:waqty_user_application/features/auth/login/data/services/login_service.dart';
import 'package:waqty_user_application/features/auth/register/data/repo/register_repo.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_service.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/repo/reseat_password_repo.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/services/reseat_password_service.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/data/repo/explore_near_people_repo.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/data/services/explore_near_people_service.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_service.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/repo/service_provider_details_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_service.dart';

import '../api/api_consumer.dart';
import '../api/app_interceptor.dart';
import '../api/http_consumer.dart';

final getIt = GetIt.instance;

class ServicesLocator {
  static Future<void> init() async {
    /// Register
    getIt.registerLazySingleton<RegisterRepo>(() => RegisterRepo(getIt()));
    getIt.registerFactory<RegisterService>(
      () => RegisterService(apiConsumer: getIt()),
    );

    /// Login
    getIt.registerLazySingleton<LoginRepo>(() => LoginRepo(getIt()));
    getIt.registerFactory<LoginService>(
      () => LoginService(apiConsumer: getIt()),
    );

    /// ForgetPassword
    getIt.registerLazySingleton<ForgetPasswordRepo>(
      () => ForgetPasswordRepo(getIt()),
    );
    getIt.registerFactory<ForgetPasswordService>(
      () => ForgetPasswordService(apiConsumer: getIt()),
    );

    /// ForgetVerifyCode
    getIt.registerLazySingleton<ForgetVerifyCodeRepo>(
      () => ForgetVerifyCodeRepo(getIt()),
    );
    getIt.registerFactory<ForgetVerifyCodeService>(
      () => ForgetVerifyCodeService(apiConsumer: getIt()),
    );

    /// ReseatPassword
    getIt.registerLazySingleton<ReseatPasswordRepo>(
      () => ReseatPasswordRepo(getIt()),
    );
    getIt.registerFactory<ReseatPasswordService>(
      () => ReseatPasswordService(apiConsumer: getIt()),
    );
   /// Home
    getIt.registerLazySingleton<HomeRepo>(
      () => HomeRepo(getIt()),
    );
    getIt.registerFactory<HomeService>(
      () => HomeService(apiConsumer: getIt()),
    );
   /// Home
    getIt.registerLazySingleton<ServiceProviderDetailsRepo>(
      () => ServiceProviderDetailsRepo(getIt()),
    );
    getIt.registerFactory<ServiceProviderDetailsService>(
      () => ServiceProviderDetailsService(apiConsumer: getIt()),
    );
 /// ExploreNearPeople
    getIt.registerLazySingleton<ExploreNearPeopleRepo>(
      () => ExploreNearPeopleRepo(getIt()),
    );
    getIt.registerFactory<ExploreNearPeopleService>(
      () => ExploreNearPeopleService(apiConsumer: getIt()),
    );

    // /// RegisterOtp
    // getIt.registerLazySingleton<SenderRegisterOtpRepo>(
    //   () => SenderRegisterOtpRepo(getIt()),
    // );
    // getIt.registerFactory<SenderRegisterOtpService>(
    //   () => SenderRegisterOtpService(apiConsumer: getIt()),
    // );

    ///core

    getIt.registerLazySingleton<AppInterceptor>(() => AppInterceptor());

    getIt.registerLazySingleton<ApiConsumer>(() => HttpConsumer(getIt()));
    getIt.registerLazySingleton(() => http.Client());

    ///shared secure
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    getIt.registerLazySingleton(() => secureStorage);
  }
}
