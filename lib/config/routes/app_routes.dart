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

      // case Routes.registerScreen:
      //   return MaterialPageRoute(builder: (_) => OnBoard1Screen());
      // case Routes.onBoard2Screen:
      //   return MaterialPageRoute(builder: (_) => OnBoard2Screen());
      // case Routes.onBoard3Screen:
      //   return MaterialPageRoute(builder: (_) => OnBoard3Screen());

      // case Routes.senderSignScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => SenderSignCubit(getIt())
      //         ..changeIsSignUpState(args['status'] == 'login' ? false : true),
      //       child: SenderSignScreen(type: args['type']),
      //     ),
      //   );
      // case Routes.senderRegisterOtpScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => SenderRegisterOtpCubit(getIt()),
      //       child: SenderRegisterOtpScreen(
      //         type: args['type'],
      //         email: args['email'],
      //         phone: args['phone'],
      //       ),
      //     ),
      //   );
      // case Routes.senderForgetOtpScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => SenderForgetOtpCubit(getIt()),
      //       child: SenderForgetOtpScreen(
      //         type: args['type'],
      //         email: args['email'],
      //       ),
      //     ),
      //   );
      // case Routes.buttonNavigationBarScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => ButtonNavigationBarCubit(),
      //       child: ButtonNavigationBarScreen(),
      //     ),
      //   );
      // case Routes.senderButtonNavigationBarScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => SenderButtonNavigationBarCubit(),
      //       child: SenderButtonNavigationBarScreen(),
      //     ),
      //   );
      // case Routes.editProfileScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => EditProfileCubit(getIt())..getMyData(),
      //       child: EditProfileScreen(),
      //     ),
      //   );
      // case Routes.changePasswordScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => ChangePasswordCubit(getIt()),
      //       child: ChangePasswordScreen(),
      //     ),
      //   );
      // case Routes.helpCenterScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => HelpCenterCubit(getIt())..getHelpCenter(),
      //       child: HelpCenterScreen(),
      //     ),
      //   );
      // case Routes.supportScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => SupportCubit(getIt())..setting(),
      //       child: SupportScreen(),
      //     ),
      //   );
      // case Routes.termsConditionsScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) =>
      //           TermsConditionsCubit(getIt())..getTermsAndConditions(),
      //       child: TermsConditionsScreen(),
      //     ),
      //   );
      // case Routes.openNewTicketScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => OpenNewTicketCubit(getIt())..getCountries(),
      //       child: OpenNewTicketScreen(),
      //     ),
      //   );
      // case Routes.openNewTicketDoneScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => OpenNewTicketDoneCubit(),
      //       child: OpenNewTicketDoneScreen(),
      //     ),
      //   );
      // case Routes.notificationScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => NotificationCubit(),
      //       child: NotificationScreen(),
      //     ),
      //   );
      // case Routes.sendNewPackageScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => SendNewPackageCubit(getIt(), getIt(), getIt())
      //         ..getPackageTypes()
      //         ..getMyAddress()
      //         ..getCountry(),
      //       child: SendNewPackageScreen(),
      //     ),
      //   );
      // case Routes.myAddressScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => MyAddressCubit(getIt())..getMyAddress(),
      //       child: MyAddressScreen(),
      //     ),
      //   );
      // case Routes.addNewAddressScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) =>
      //           AddNewAddressCubit(getIt(), getIt())..getCites(),
      //       child: AddNewAddressScreen(),
      //     ),
      //   );
      // case Routes.updateAddressScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => UpdateAddressCubit(getIt(), getIt())
      //         ..getAddressDetails(args['id'])
      //         ..getCites(),
      //       child: UpdateAddressScreen(id: args['id']),
      //     ),
      //   );
      // case Routes.sendNewPackageDoneScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) => SendNewPackageDoneCubit(),
      //       child: SendNewPackageDoneScreen(id: args['id']),
      //     ),
      //   );
      // case Routes.requestDetailsScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (context) =>
      //           RequestDetailsCubit(getIt())..myRequests(args['id']),
      //       child: RequestDetailsScreen(id: args['id']),
      //     ),
      //   );

      default:
        return null;
    }
  }
}
