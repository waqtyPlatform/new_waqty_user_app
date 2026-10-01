import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:get_it/get_it.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/repo/forget_password_repo.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/services/forget_password_service.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/repo/forget_verify_code_repo.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/services/forget_verify_code_service.dart';
import 'package:waqty_user_application/features/auth/login/data/repo/login_repo.dart';
import 'package:waqty_user_application/features/auth/login/data/services/login_service.dart';
import 'package:waqty_user_application/features/auth/register/data/repo/register_repo.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_service.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/repo/register_verify_code_repo.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/services/register_verify_code_service.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/repo/reseat_password_repo.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/services/reseat_password_service.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/data/repo/explore_near_people_repo.dart';
import 'package:waqty_user_application/features/explore_near_people/explore_near_people/data/services/explore_near_people_service.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_service.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/repo/service_provider_details_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_service.dart';

import '../api/api_consumer.dart';
import '../api/disconnected_api_consumer.dart';

final getIt = GetIt.instance;

class ServicesLocator {
  static Future<void> init() async {
    /// Register
    getIt.registerLazySingleton<RegisterRepo>(() => RegisterRepo(getIt()));
    getIt.registerLazySingleton<RegisterService>(
      () => RegisterService(apiConsumer: getIt()),
    );

    /// Login
    getIt.registerLazySingleton<LoginRepo>(() => LoginRepo(getIt()));
    getIt.registerLazySingleton<LoginService>(
      () => LoginService(apiConsumer: getIt()),
    );

    /// ForgetPassword
    getIt.registerLazySingleton<ForgetPasswordRepo>(
      () => ForgetPasswordRepo(getIt()),
    );
    getIt.registerLazySingleton<ForgetPasswordService>(
      () => ForgetPasswordService(apiConsumer: getIt()),
    );

    /// ForgetVerifyCode
    getIt.registerLazySingleton<ForgetVerifyCodeRepo>(
      () => ForgetVerifyCodeRepo(getIt()),
    );
    getIt.registerLazySingleton<ForgetVerifyCodeService>(
      () => ForgetVerifyCodeService(apiConsumer: getIt()),
    );

    /// RegisterVerifyCode
    getIt.registerLazySingleton<RegisterVerifyCodeRepo>(
      () => RegisterVerifyCodeRepo(getIt()),
    );
    getIt.registerLazySingleton<RegisterVerifyCodeService>(
      () => RegisterVerifyCodeService(apiConsumer: getIt()),
    );

    /// ReseatPassword
    getIt.registerLazySingleton<ReseatPasswordRepo>(
      () => ReseatPasswordRepo(getIt()),
    );
    getIt.registerLazySingleton<ReseatPasswordService>(
      () => ReseatPasswordService(apiConsumer: getIt()),
    );

    /// Home
    getIt.registerLazySingleton<HomeRepo>(() => HomeRepo(getIt()));
    getIt.registerLazySingleton<HomeService>(
      () => HomeService(apiConsumer: getIt()),
    );

    /// Home
    getIt.registerLazySingleton<ServiceProviderDetailsRepo>(
      () => ServiceProviderDetailsRepo(getIt()),
    );
    getIt.registerLazySingleton<ServiceProviderDetailsService>(
      () => ServiceProviderDetailsService(apiConsumer: getIt()),
    );

    /// ExploreNearPeople
    getIt.registerLazySingleton<ExploreNearPeopleRepo>(
      () => ExploreNearPeopleRepo(getIt()),
    );
    getIt.registerLazySingleton<ExploreNearPeopleService>(
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

    getIt.registerLazySingleton<ApiConsumer>(() => DisconnectedApiConsumer());

    ///shared secure
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    getIt.registerLazySingleton(() => secureStorage);
  }
}
