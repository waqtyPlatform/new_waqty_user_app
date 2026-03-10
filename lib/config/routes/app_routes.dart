import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/auth/forget_password/logic/forget_password_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_password/ui/forget_password_screen.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/logic/forget_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/ui/forget_verify_code_screen.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';
import 'package:waqty_user_application/features/auth/login/ui/login_screen.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/ui/register_screen.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/logic/register_verify_code_cubit.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/ui/register_verify_code_screen.dart';
import 'package:waqty_user_application/features/auth/reseat_password/logic/reseat_password_cubit.dart';
import 'package:waqty_user_application/features/auth/reseat_password/ui/reseat_password_screen.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_cubit.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/ui/button_navigation_bar_screen.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_cubit.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/service_provider_details_screen.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final dynamic args = settings.arguments;
    switch (settings.name) {
      case Routes.registerScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => RegisterCubit(getIt()),
            child: RegisterScreen(),
          ),
        );
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => LoginCubit(getIt()),
            child: LoginScreen(),
          ),
        );

      case Routes.forgetPasswordScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ForgetPasswordCubit(getIt()),
            child: ForgetPasswordScreen(),
          ),
        );
      case Routes.forgetVerifyCodeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ForgetVerifyCodeCubit(getIt(), getIt()),
            child: ForgetVerifyCodeScreen(email: args['email']),
          ),
        );
      case Routes.registerVerifyCodeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => RegisterVerifyCodeCubit(
              getIt(),
              args['email'],
              args['isSndCodeFrommServer'],
            )..sendInitialCode(args['email']),
            child: RegisterVerifyCodeScreen(email: args['email']),
          ),
        );
      case Routes.reseatPasswordScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ReseatPasswordCubit(getIt()),
            child: ReseatPasswordScreen(
              email: args['email'],
              code: args['code'],
            ),
          ),
        );
      case Routes.buttonNavigationBarScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ButtonNavigationBarCubit(),
            child: ButtonNavigationBarScreen(),
          ),
        );
      case Routes.serviceProviderDetailsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ServiceProviderDetailsCubit(getIt()),
            child: ServiceProviderDetailsScreen(),
          ),
        );

      default:
        return null;
    }
  }
}
