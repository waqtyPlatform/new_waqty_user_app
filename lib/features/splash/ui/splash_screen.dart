import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/splash/logic/splash_cubit.dart';
import 'package:waqty_user_application/features/splash/logic/splash_state.dart';
import 'package:waqty_user_application/features/splash/ui/widgets/splash_logo_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          // بنمسح الـ splash من الـ stack — العميل مايرجعش عليها بزرار الرجوع.
          if (state is GoToHomeState) {
            context.pushNamedAndRemoveUntil(
              Routes.buttonNavigationBarScreen,
              predicate: (_) => false,
            );
          } else if (state is GoToLoginState) {
            context.pushNamedAndRemoveUntil(
              Routes.loginScreen,
              predicate: (_) => false,
            );
          }
        },
        child: const Center(child: SplashLogoWidget()),
      ),
    );
  }
}
