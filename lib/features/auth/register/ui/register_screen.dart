import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/widgets/auth_header_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/change_language_icon.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_already_have_account_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_button_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_email_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_name_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_gender_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_birth_date_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_password_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_phone_number_widget.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_terms_and_conditions_widget.dart';

/// شاشة التسجيل — ٦ حقول.
///
/// اللابلات كانت ٦ `Text` + ٦ `verticalSpace(6)` مكتوبين هنا. دلوقتي كل
/// حقل شايل لابله (من الـ DNA: `label positioned above the field`)،
/// فالشاشة بقت **قايمة حقول** مش تخطيط بالإيد.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.pageGutter.w,
          ),
          child: Form(
            key: RegisterCubit.get(context).registerKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthHeaderWidget(
                  showLogo: true,
                  trailing: const ChangeLanguageIconWidget(),
                  title: context.tr('register.title'),
                  description: context.tr('register.description'),
                ),

                const RegisterNameWidget(),
                verticalSpace(AppSpacing.s16),
                const RegisterPhoneNumberWidget(),
                verticalSpace(AppSpacing.s16),
                const RegisterEmailWidget(),
                verticalSpace(AppSpacing.s16),
                const RegisterGenderWidget(),
                verticalSpace(AppSpacing.s16),
                const RegisterBirthDateWidget(),
                verticalSpace(AppSpacing.s16),
                const RegisterPasswordWidget(),

                verticalSpace(AppSpacing.s32),
                const RegisterButtonWidget(),
                verticalSpace(AppSpacing.s16),
                const RegisterTermsAndConditionsWidget(),
                verticalSpace(AppSpacing.s40),
                const RegisterAlreadyHaveAccountWidget(),
                verticalSpace(AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
