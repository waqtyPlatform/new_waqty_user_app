import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:get_it/get_it.dart';
import 'package:waqty_user_application/features/register/data/repo/register_repo.dart';
import 'package:waqty_user_application/features/register/data/services/register_service.dart';

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
