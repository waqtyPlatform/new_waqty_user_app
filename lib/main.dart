import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/firebase_notification_service.dart';
import 'package:waqty_user_application/core/services/local_notification_service.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/firebase_options.dart';
import 'package:waqty_user_application/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/cache_helper.dart';
import 'core/services/services_locator.dart';
import 'core/utils/app_constant.dart';
import 'observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await EasyLocalization.ensureInitialized();
  await ServicesLocator.init();
  await CacheHelper.init();
  await MyConnectivity.initialise();
  await getIt<LocalNotificationService>().initialize();
  await getIt<FirebaseNotificationService>().initialize();
  // PusherService.initPusher();

  Bloc.observer = Observer();

  try {
    await checkIsFirstRunForApp();
    await checkIfLoggedInUser();
    await checkIfIsInBoardingUser();
  } catch (e) {
    isLoggedInUser = false;
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      saveLocale: true,
      startLocale: const Locale('ar', 'EG'),
      path: 'assets/languages',
      fallbackLocale: const Locale('ar', 'EG'),
      child: MyApp(
        navigateWidget: isLoggedInUser
            ? Routes.buttonNavigationBarScreen
            : (isOnBoarding
                  ? Routes.onboardingAppointmentsScreen
                  : Routes.loginScreen),
      ),
    ),
  );
}

Future<void> checkIsFirstRunForApp() async {
  final isFirstRun = await CacheHelper.getBool(
    ConstantKeys.saveIsFirstRunToShared,
  );

  if (isFirstRun) {
    await CacheHelper.removeSecureData(ConstantKeys.saveTokenToShared);
    await CacheHelper.removeSecureData(ConstantKeys.saveUserTypeToShared);
    await CacheHelper.setData(ConstantKeys.saveIsFirstRunToShared, false);
  }
}

Future<void> checkIfLoggedInUser() async {
  String? userToken = await CacheHelper.getSecuredString(
    ConstantKeys.saveTokenToShared,
  );
  isLoggedInUser = !(userToken == null || userToken.isEmpty);
}

Future<void> checkIfIsInBoardingUser() async {
  isOnBoarding = await CacheHelper.getBool(
    ConstantKeys.saveIsShowIsBoardingToShared,
  );
}
