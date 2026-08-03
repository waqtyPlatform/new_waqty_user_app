import 'dart:ui' as ui;

import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class RegisterPhoneNumberWidget extends StatelessWidget {
  const RegisterPhoneNumberWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) {
        return current is OnChangeSelectedFieldState;
      },
      builder: (context, state) {
        return AppTextFormField(
          hintText: context.tr('register.enterPhoneText'),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          contentPadding: EdgeInsets.symmetric(
            vertical: 11.h,
            horizontal: 12.w,
          ),
          textStyle: TextStyles.font16greyColor900Weight400,
          controller: RegisterCubit.get(context).registerPhoneController,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greyColor1001, width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),

          // **كود الدولة لازم يفضل LTR.**
          //
          // الواجهة عربي، والـ RTL بيقلب «+20» لـ «20+» — وده مش رقم
          // موجود. أكواد الدول والتليفونات نص لاتيني حتى جوه واجهة
          // عربي، وقلبها بيخلي العميل يشك إنه اختار بلد غلط.
          prefixIcon: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: SizedBox(
            width: 115,
            child: CountryCodePicker(
              onChanged: (CountryCode code) {
                RegisterCubit.get(context).registerCountryCodeController.text =
                    code.toString();
              },
              initialSelection: 'Eg',
              favorite: const ['Eg'],
              flagWidth: 20,
              showFlag: true,
              showCountryOnly: true,
              showOnlyCountryWhenClosed: false,
              alignLeft: true,
              textStyle: TextStyle(color: AppColors.greyColor4002),
              flagDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greenColor500, width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return context.tr('register.enterPhoneText2');
            }
            return null;
          },
          backgroundColor: RegisterCubit.get(context).selectedFieldNumber == 2
              ? AppColors.greenColor505
              : AppColors.whiteColor,
          onTap: () {
            RegisterCubit.get(context).changeSelectedField(2);
          },
          onTapOutside: () {
            RegisterCubit.get(context).changeSelectedField(0);
          },
          keyboardType: TextInputType.phone,
        );
      },
    );
  }
}
