import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/app_text_field.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class RegisterBirthDateWidget extends StatelessWidget {
  const RegisterBirthDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) {
        return current is OnChangeBirthDateState ||
            current is OnChangeSelectedFieldState;
      },
      builder: (context, state) {
        return AppTextFormField(
          hintText: context.tr('register.enterBirthDateText'),
          hintStyle: TextStyles.font16greyColor4002Weight500,
          contentPadding: EdgeInsets.symmetric(
            vertical: 11.h,
            horizontal: 12.w,
          ),
          textStyle: TextStyles.font16greyColor900Weight400,
          controller: RegisterCubit.get(context).registerBirthDateController,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greyColor1001, width: 1),
            borderRadius: BorderRadius.circular(10.r),
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
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            color: AppColors.greyColor4002,
            size: 20.sp,
          ),
          backgroundColor: RegisterCubit.get(context).selectedFieldNumber == 5
              ? AppColors.greenColor505
              : AppColors.whiteColor,
          onTap: () {
            RegisterCubit.get(context).changeSelectedField(5);
            _selectDate(context);
          },
          onTapOutside: () {
            RegisterCubit.get(context).changeSelectedField(0);
          },
          keyboardType: TextInputType.none,
          validator: (value) {
            return null;
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1900, 5, 20),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.greenColor500,
              onPrimary: AppColors.whiteColor,
              onSurface: AppColors.greyColor900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      RegisterCubit.get(context).changeBirthDate(formattedDate);
    }
  }
}
