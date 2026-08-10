import 'dart:ui' as ui;

import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';

class RegisterPhoneNumberWidget extends StatelessWidget {
  const RegisterPhoneNumberWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RegisterCubit.get(context);

    return AppFieldWidget(
      label: context.tr('register.phoneText'),
      child: AppTextFormField(
        hintText: context.tr('register.enterPhoneText'),
        controller: cubit.registerPhoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.telephoneNumber],
        prefixIcon: _CountryPrefix(
          onChanged: (code) => cubit.registerCountryCodeController.text = code,
        ),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? context.tr('register.enterPhoneText2')
            : null,
      ),
    );
  }
}

/// **لازم يفضل LTR** — الـ RTL بيقلب «+20» لـ «20+»، وده مش رقم موجود.
class _CountryPrefix extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _CountryPrefix({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SizedBox(
        width: 115.w,
        child: CountryCodePicker(
          onChanged: (CountryCode code) => onChanged(code.toString()),
          initialSelection: 'Eg',
          favorite: const ['Eg'],
          flagWidth: 20,
          showFlag: true,
          showCountryOnly: true,
          showOnlyCountryWhenClosed: false,
          alignLeft: true,
          dialogBackgroundColor: AppSemanticColors.surfaceRaised,
          dialogTextStyle: AppTextStyles.bodyMd,
          searchStyle: AppTextStyles.bodyMd,
          textStyle: AppTextStyles.bodyMd.copyWith(
            color: AppSemanticColors.textSecondary,
          ),
          flagDecoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }
}
