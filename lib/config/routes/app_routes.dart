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
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_cubit.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/booking_details_screen.dart';
import 'package:waqty_user_application/features/booking/booking_success/ui/booking_success_screen.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/logic/button_navigation_bar_cubit.dart';
import 'package:waqty_user_application/features/home/button_navigation_bar/ui/button_navigation_bar_screen.dart';
import 'package:waqty_user_application/features/providers/providers_list/logic/providers_list_cubit.dart';
import 'package:waqty_user_application/features/providers/providers_list/ui/providers_list_screen.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/logic/service_provider_details_cubit.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/ui/service_provider_details_screen.dart';
import 'package:waqty_user_application/features/splash/logic/splash_cubit.dart';
import 'package:waqty_user_application/features/splash/ui/splash_screen.dart';
import 'package:waqty_user_application/features/providers/providers_list/data/repo/providers_list_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/repo/service_provider_details_repo.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/repo/booking_details_repo.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/repo/reassignment_repo.dart';
import 'package:waqty_user_application/features/booking/reassignment/logic/reassignment_cubit.dart';
import 'package:waqty_user_application/features/booking/reassignment/ui/reassignment_screen.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/repo/phone_verification_repo.dart';
import 'package:waqty_user_application/features/account/phone_verification/logic/phone_verification_cubit.dart';
import 'package:waqty_user_application/features/account/phone_verification/ui/phone_verification_screen.dart';
import 'package:waqty_user_application/features/account/payments/data/repo/payments_repo.dart';
import 'package:waqty_user_application/features/account/payments/logic/payments_cubit.dart';
import 'package:waqty_user_application/features/account/payments/ui/payments_screen.dart';
import 'package:waqty_user_application/core/api/session_store.dart';
import 'package:waqty_user_application/features/splash/data/repo/app_gate_repo.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final dynamic args = settings.arguments;
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => SplashCubit(
              getIt<AppGateRepo>(),
              getIt<SessionStore>(),
            )..checkSession(),
            child: const SplashScreen(),
          ),
        );
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
        final navArgs = args is Map ? args : const <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ButtonNavigationBarCubit(
              getIt<HomeRepo>(),
              initialIndex: (navArgs['initialIndex'] as int?) ?? 0,
            )..start(),
            child: const ButtonNavigationBarScreen(),
          ),
        );

      case Routes.bookingSuccessScreen:
        return MaterialPageRoute(builder: (_) => const BookingSuccessScreen());

      case Routes.paymentsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => PaymentsCubit(getIt<PaymentsRepo>())..load(),
            child: const PaymentsScreen(),
          ),
        );

      case Routes.phoneVerificationScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                PhoneVerificationCubit(getIt<PhoneVerificationRepo>()),
            child: const PhoneVerificationScreen(),
          ),
        );

      case Routes.reassignmentScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                ReassignmentCubit(getIt<ReassignmentRepo>())..start(),
            child: const ReassignmentScreen(),
          ),
        );

      case Routes.bookingDetailsScreen:
        final bookingArgs = args is Map ? args : const <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => BookingDetailsCubit(
              getIt<BookingDetailsRepo>(),
              bookingUuid: (bookingArgs['bookingUuid'] as String?) ?? '',
            )..loadBooking(),
            child: const BookingDetailsScreen(),
          ),
        );
      case Routes.serviceProviderDetailsScreen:
        final detailsArgs = args is Map ? args : const <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ServiceProviderDetailsCubit(
              getIt<ServiceProviderDetailsRepo>(),
              providerUuid: (detailsArgs['providerUuid'] as String?) ?? '',
            )..loadDetails(),
            child: const ServiceProviderDetailsScreen(),
          ),
        );

      case Routes.providersListScreen:
        // بنتأكد إن الـ args فعلاً Map قبل ما نقرا منها — الحالات القديمة
        // بتقرا `args['email']` على طول، فأي دخول من غير arguments بيوقّع.
        final map = args is Map ? args : const <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ProvidersListCubit(
              getIt<ProvidersListRepo>(),
              initialCategoryUuid: map['categoryUuid'] as String?,
            )..loadInitial(),
            // الـ Scaffold والـ AppBar مكانهم هنا مش جوه الشاشة.
            //
            // نفس الشاشة بتتعرض كتبويب جوه `ButtonNavigationBarScreen` اللي
            // عنده Scaffold أصلاً — ولو كانت شايلة Scaffold بتاعها، حالة
            // التبويب بتبقى Scaffold جوه Scaffold. الشاشة بقت بلا Scaffold،
            // وحالة الـ route بس هي اللي بتلفّها.
            child: Scaffold(
              appBar: AppBar(title: const Text('الأماكن')),
              body: ProvidersListScreen(
                autofocusSearch: map['autofocusSearch'] == true,
              ),
            ),
          ),
        );

      default:
        return null;
    }
  }
}
