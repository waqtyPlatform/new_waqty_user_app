import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/widgets/auth_header_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_button_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_don_not_already_have_account_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_password_widget.dart';
import 'package:waqty_user_application/features/auth/login/ui/widgets/login_phone_number_widget.dart';

/// شاشة الدخول.
///
/// ## اللابلات نزلت جوه الحقول
///
/// كانت `Text(...)` + `verticalSpace(6)` قبل كل حقل، مكتوبين في الشاشة.
/// دلوقتي اللابل باراميتر في `AppTextFormField` (من الـ DNA: `label
/// positioned above the field`) — يعني المسافة بين اللابل وحقله بقت رقم
/// واحد في الأبلكيشن كله بدل ٦ متكتوبة في ١١ موضع.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // الخلفية من `scaffoldBackgroundColor` — كانت أبيض متكتوب بالإيد،
      // وده كان بيمنع الصفحة الدافية **وبيطلّع شاشة بيضا في الوضع الغامق**.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.pageGutter.w,
          ),
          child: Form(
            key: LoginCubit.get(context).loginKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthHeaderWidget(
                  showLogo: true,
                  title: context.tr('login.title'),
                  description: context.tr('login.description'),
                ),

                const LoginPhoneNumberWidget(),
                verticalSpace(AppSpacing.s16),

                const LoginPasswordWidget(),
                verticalSpace(AppSpacing.s8),

                // الحد الأدنى للمس جاي من `textButtonTheme`.
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () =>
                        context.pushNamed(Routes.forgetPasswordScreen),
                    child: Text(context.tr("login.forgetPasswordText")),
                  ),
                ),

                verticalSpace(AppSpacing.s32),
                const LoginButtonWidget(),

                // **الدخول بجوجل وآبل اتشالوا — كانوا زراير ميتة.**
                //
                // `onTap: () {}` في الاتنين، ومفيش ولا حزمة في `pubspec.yaml`
                // (لا `google_sign_in` ولا `sign_in_with_apple` ولا
                // `firebase_auth`).
                //
                // زرار دخول ميت أوحش من زرار مش موجود: العميل بيدوس، مايحصلش
                // حاجة، فيستنتج إن الأبلكيشن باظ — وده على **أول شاشة**
                // يشوفها. والفاصل «أو المتابعة باستخدام» اتشال معاهم لأنه
                // بيقدّم حاجة مابقتش موجودة.
                verticalSpace(AppSpacing.s48),
                const LoginDonNotAlreadyHaveAccountWidget(),
                verticalSpace(AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
