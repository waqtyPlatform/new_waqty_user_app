import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/account/profile/logic/profile_cubit.dart';
import 'package:waqty_user_application/features/account/profile/logic/profile_state.dart';
import 'package:waqty_user_application/features/account/profile/ui/widgets/profile_gender_field.dart';
import 'package:waqty_user_application/features/account/profile/ui/widgets/profile_photo.dart';
import 'package:waqty_user_application/features/account/profile/ui/widgets/profile_text_field_block.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ProfileCubit.get(context);
    cubit.initGender(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfilePhoto(),
          SizedBox(height: 12.h),
          ProfileTextFieldBlock(
            labelKey: 'accountProfile.nameLabel',
            hintKey: 'register.enterNameText',
            controller: cubit.nameController,
            border: false,
          ),
          SizedBox(height: 12.h),
          ProfileTextFieldBlock(
            labelKey: 'accountProfile.emailLabel',
            hintKey: 'register.enterEmailText',
            controller: cubit.emailController,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 12.h),
          BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (previous, current) =>
                current is ProfileGenderChangedState,
            builder: (context, state) {
              return ProfileGenderField(
                labelKey: 'accountProfile.genderLabel',
                value: cubit.selectedGender!,
                items: cubit.genderItems(context),
                onChanged: cubit.changeGender,
              );
            },
          ),
          SizedBox(height: 12.h),
          ProfileTextFieldBlock(
            labelKey: 'accountProfile.birthDateLabel',
            hintKey: 'register.enterBirthDateText',
            controller: cubit.birthDateController,
            textAlign: TextAlign.left,
            keyboardType: TextInputType.none,
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              color: AppColors.greyColor4002,
              size: 20.sp,
            ),
            onTap: () => cubit.selectBirthDate(context),
          ),
        ],
      ),
    );
  }
}
