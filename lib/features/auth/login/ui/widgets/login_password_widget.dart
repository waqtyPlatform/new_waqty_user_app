import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';

/// حقل كلمة السر.
///
/// ## الـ `BlocBuilder` اتشال خالص
///
/// كان بيتفرّج على `IsPasswordVisibleState` عشان يقلب أيقونة العين —
/// يعني **حالة في الـ cubit موجودة لشكل زرار**. `AppPasswordFieldWidget`
/// بتاع الكيت شايل الحالة دي جواه، فالـ cubit خفّ تلات أعضاء
/// (`isPasswordVisibleLogin` · `changePasswordLoginState` ·
/// `IsPasswordVisibleState`) وكل ضغطة على العين بقت بتبني الحقل بس بدل
/// ما تبني الشاشة.
///
/// وده مش خرق لقاعدة «مفيش `setState`»: الـ`setState` جوّه الكيت، واللي
/// بيقولها هو نفسه اللي كاتب إن الكيت مابيشحنش نظام حالة.
class LoginPasswordWidget extends StatelessWidget {
  const LoginPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = LoginCubit.get(context);

    return AppFieldWidget(
      label: context.tr('login.passwordText'),
      child: AppPasswordFieldWidget(
        hintText: context.tr('login.enterPasswordText'),
        controller: cubit.loginPasswordController,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.password],
        validator: (value) => (value == null || value.isEmpty)
            ? context.tr('login.enterPasswordText2')
            : null,
      ),
    );
  }
}
