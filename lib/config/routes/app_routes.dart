import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/account/change_phone/logic/change_phone_cubit.dart';
import 'package:waqty_user_application/features/account/change_phone/ui/change_phone_screen.dart';
import 'package:waqty_user_application/features/account/confirm_phone/logic/confirm_phone_cubit.dart';
import 'package:waqty_user_application/features/account/confirm_phone/ui/confirm_phone_screen.dart';
import 'package:waqty_user_application/features/account/help/ui/help_screen.dart';
import 'package:waqty_user_application/features/account/language/logic/language_cubit.dart';
import 'package:waqty_user_application/features/account/language/ui/language_screen.dart';
import 'package:waqty_user_application/features/account/legal/logic/legal_cubit.dart';
import 'package:waqty_user_application/features/account/legal/ui/legal_screen.dart';
import 'package:waqty_user_application/features/account/packages_following/logic/packages_following_cubit.dart';
import 'package:waqty_user_application/features/account/packages_following/ui/packages_following_screen.dart';
import 'package:waqty_user_application/features/account/profile/logic/profile_cubit.dart';
import 'package:waqty_user_application/features/account/profile/ui/profile_screen.dart';
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
import 'package:waqty_user_application/features/home/subcategories/data/repo/subcategories_repo.dart';
import 'package:waqty_user_application/features/home/subcategories/logic/subcategories_cubit.dart';
import 'package:waqty_user_application/features/home/subcategories/ui/subcategories_screen.dart';
import 'package:waqty_user_application/features/home/providers/data/repo/providers_repo.dart';
import 'package:waqty_user_application/features/home/providers/logic/providers_cubit.dart';
import 'package:waqty_user_application/features/home/providers/ui/providers_screen.dart';
import 'package:waqty_user_application/features/onboarding/appointments/ui/onboarding_appointments_screen.dart';
import 'package:waqty_user_application/features/onboarding/balance/ui/onboarding_balance_screen.dart';
import 'package:waqty_user_application/features/onboarding/booking/ui/onboarding_booking_screen.dart';
import 'package:waqty_user_application/features/onboarding/notifications/ui/onboarding_notifications_screen.dart';
import 'package:waqty_user_application/features/onboarding/start/ui/onboarding_start_screen.dart';
import 'package:waqty_user_application/features/home/provider_details/logic/provider_details_cubit.dart';
import 'package:waqty_user_application/features/home/provider_details/ui/provider_details_screen.dart';
import 'package:waqty_user_application/features/home/provider_booking/ui/provider_booking_screen.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final dynamic args = settings.arguments;
    switch (settings.name) {
      case Routes.registerScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => RegisterCubit(getIt())
              ..fillFromSocialUser(
                args is Map<String, dynamic> ? args['social_user'] : null,
              ),
            child: RegisterScreen(),
          ),
        );
      case Routes.onboardingAppointmentsScreen:
        return MaterialPageRoute(
          builder: (_) => const OnboardingAppointmentsScreen(),
        );
      case Routes.onboardingBookingScreen:
        return MaterialPageRoute(
          builder: (_) => const OnboardingBookingScreen(),
        );
      case Routes.onboardingNotificationsScreen:
        return MaterialPageRoute(
          builder: (_) => const OnboardingNotificationsScreen(),
        );
      case Routes.onboardingBalanceScreen:
        return MaterialPageRoute(
          builder: (_) => const OnboardingBalanceScreen(),
        );
      case Routes.onboardingStartScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingStartScreen());
      case Routes.languageScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) =>
                LanguageCubit(initialLanguageCode: context.locale.languageCode),
            child: const LanguageScreen(),
          ),
        );
      case Routes.profileScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProfileCubit(),
            child: const ProfileScreen(),
          ),
        );
      case Routes.changePhoneScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ChangePhoneCubit(),
            child: const ChangePhoneScreen(),
          ),
        );
      case Routes.confirmPhoneScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ConfirmPhoneCubit()..startResendTimer(),
            child: const ConfirmPhoneScreen(),
          ),
        );
      case Routes.packagesFollowingScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => PackagesFollowingCubit(),
            child: const PackagesFollowingScreen(),
          ),
        );
      case Routes.helpScreen:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case Routes.legalScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => LegalCubit(),
            child: const LegalScreen(),
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
            child: ForgetVerifyCodeScreen(
              email: args['email'],
              method: args['method'] ?? 'email',
              channel: args['channel'] ?? 'email',
              sentTo: args['sent_to'] ?? '',
            ),
          ),
        );
      case Routes.registerVerifyCodeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => RegisterVerifyCodeCubit(
              getIt(),
              args['email'],
              args['isSndCodeFrommServer'],
              args['otp_channel'] ?? 'email',
              args['verify_endpoint'] ?? '/api/user/auth/verify-email',
              args['can_choose_otp_channel'] ?? false,
            ),
            child: RegisterVerifyCodeScreen(
              email: args['email'],
              method: args['method'] ?? 'email',
              otpChannel: args['otp_channel'] ?? 'email',
              verifyEndpoint:
                  args['verify_endpoint'] ?? '/api/user/auth/verify-email',
            ),
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
      case Routes.providerDetailsScreen:
        final providerUuid = args is Map<String, dynamic>
            ? (args['provider_uuid'] ?? args['uuid'])?.toString() ?? ''
            : args?.toString() ?? '';
        if (providerUuid.isEmpty) return null;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                ProviderDetailsCubit(getIt())..load(providerUuid),
            child: ProviderDetailsScreen(providerUuid: providerUuid),
          ),
        );
      case Routes.providerBookingScreen:
        if (args is! Map<String, dynamic>) return null;
        final providerUuid = args['provider_uuid']?.toString() ?? '';
        final branchUuid = args['branch_uuid']?.toString() ?? '';
        if (providerUuid.isEmpty || branchUuid.isEmpty) return null;
        return MaterialPageRoute(
          builder: (_) => ProviderBookingScreen(
            providerUuid: providerUuid,
            branchUuid: branchUuid,
            providerName: args['provider_name']?.toString() ?? '',
          ),
        );
      case Routes.subcategoriesScreen:
        final categoryUuid = args is Map<String, dynamic>
            ? args['category_uuid']?.toString() ?? ''
            : '';
        final title = args is Map<String, dynamic>
            ? args['title']?.toString() ?? ''
            : '';
        if (categoryUuid.isEmpty) return null;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                SubcategoriesCubit(getIt<SubcategoriesRepo>())
                  ..loadSubcategories(categoryUuid: categoryUuid),
            child: SubcategoriesScreen(
              title: title,
              categoryUuid: categoryUuid,
            ),
          ),
        );
      case Routes.providersScreen:
        final categoryUuid = args is Map<String, dynamic>
            ? args['category_uuid']?.toString() ?? ''
            : '';
        final subcategoryUuid = args is Map<String, dynamic>
            ? args['subcategory_uuid']?.toString() ?? ''
            : '';
        final title = args is Map<String, dynamic>
            ? args['title']?.toString() ?? ''
            : '';
        if (categoryUuid.isEmpty && subcategoryUuid.isEmpty) return null;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProvidersCubit(
              getIt<ProvidersRepo>(),
              categoryUuid: categoryUuid.isEmpty ? null : categoryUuid,
              subcategoryUuid: subcategoryUuid.isEmpty ? null : subcategoryUuid,
            )..loadProviders(),
            child: ProvidersScreen(
              title: title,
              categoryUuid: categoryUuid.isEmpty ? null : categoryUuid,
              subcategoryUuid: subcategoryUuid.isEmpty ? null : subcategoryUuid,
            ),
          ),
        );

      default:
        return null;
    }
  }
}
