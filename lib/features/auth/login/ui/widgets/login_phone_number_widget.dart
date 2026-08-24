import 'dart:ui' as ui;

import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/login/logic/login_cubit.dart';

/// حقل التليفون.
///
/// **مالوش `BlocBuilder`.** كان ملفوف في واحد بيتفرّج على
/// `OnChangeSelectedFieldState` عشان يلوّن خلفية الحقل أخضر فاتح وهو مركّز.
/// الحقل دلوقتي بياخد **حد باللمسة** من `inputDecorationTheme` وقت التركيز —
/// نفس الإشارة من غير حالة في الـ cubit ولا إعادة بناء عند كل ضغطة.
class LoginPhoneNumberWidget extends StatelessWidget {
  const LoginPhoneNumberWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = LoginCubit.get(context);

    return AppFieldWidget(
      label: context.tr("login.phoneText"),
      child: AppTextFormField(
        hintText: context.tr('login.enterPhoneText'),
        controller: cubit.loginPhoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.telephoneNumber],
        prefixIcon: _CountryPrefix(
          onChanged: (code) => cubit.loginCountryCodeController.text = code,
        ),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? context.tr('login.enterPhoneText2')
            : null,
      ),
    );
  }
}

/// منتقي كود الدولة.
///
/// **لازم يفضل LTR.** الواجهة عربي، والـ RTL بيقلب «+20» لـ «20+» — وده مش
/// رقم موجود. أكواد الدول والتليفونات نص لاتيني حتى جوه واجهة عربي، وقلبها
/// بيخلي العميل يشك إنه اختار بلد غلط.
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
          // مصر — السوق اللي الأبلكيشن بيخدمه.
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
