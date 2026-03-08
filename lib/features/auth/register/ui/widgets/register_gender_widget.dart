import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_drop_down_field.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class GenderItem {
  final String value;
  final String name;

  GenderItem({required this.value, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderItem &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class RegisterGenderWidget extends StatelessWidget {
  const RegisterGenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final genderItems = [
      GenderItem(value: 'male', name: context.tr('register.maleText')),
      GenderItem(value: 'female', name: context.tr('register.femaleText')),
    ];

    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) {
        return current is OnChangeGenderState ||
            current is OnChangeSelectedFieldState;
      },
      builder: (context, state) {
        final cubit = RegisterCubit.get(context);
        return AppDropDownField(
          hintText: context.tr('register.selectGenderText'),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          textStyle: TextStyles.font16greyColor900Weight400,
          items: genderItems,
          backgroundColor: cubit.selectedFieldNumber == 4
              ? AppColors.greenColor505
              : AppColors.whiteColor,
          contentPadding: EdgeInsets.symmetric(
            vertical: 11.h,
            horizontal: 12.w,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greyColor1001, width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: cubit.selectedFieldNumber == 4
                  ? AppColors.greenColor500
                  : AppColors.greyColor1001,
              width: 1,
            ),
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
          onChanged: (item) {
            RegisterCubit.get(context).changeGender((item as GenderItem));
          },
          onTap: () {
            RegisterCubit.get(context).changeSelectedField(4);
          },
          onTapOutside: () {
            RegisterCubit.get(context).changeSelectedField(0);
          },
        );
      },
    );
  }
}
