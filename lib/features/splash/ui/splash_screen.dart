import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/splash/logic/splash_cubit.dart';
import 'package:waqty_user_application/features/splash/logic/splash_state.dart';
import 'package:waqty_user_application/features/splash/ui/widgets/splash_logo_widget.dart';
import 'package:waqty_user_application/core/models/app_gate_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

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
          } else if (state is AppGateBlockedState) {
            _showGate(context, state.gate);
          }
        },
        child: const Center(child: SplashLogoWidget()),
      ),
    );
  }

  /// حاجز صيانة أو تحديث إجباري.
  ///
  /// ⚠ **غير قابل للإغلاق ومفيش «تخطّي».** لو العميل يقدر يقفله،
  /// هيكمّل على نسخة السيرفر مش شايلها — وهيفضل يشوف أخطاء مش فاهمها.
  /// الزرار الوحيد بيودي للمتجر، ومابيتعرضش لو مفيش لينك.
  void _showGate(BuildContext context, AppGateUiModel gate) {
    AppDialogWidget.show<void>(
      context,
      // ⚠ **مايتقفلش بالدوس برّه.** حاجز يتقفل مش حاجز.
      barrierDismissible: false,
      icon: gate.action == AppGateAction.maintenance
          ? Icons.build_circle_outlined
          : Icons.system_update_rounded,
      title: gate.title,
      message: gate.message,
      actions: (dialogContext) => [
        if (gate.storeUrl.isNotEmpty)
          AppButtonWidget(
            label: 'حدّث دلوقتي',
            onPressed: () => AppConstant.openUrl(gate.storeUrl),
          ),
      ],
    );
  }
}
