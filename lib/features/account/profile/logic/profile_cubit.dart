import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/account/profile/logic/profile_state.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_gender_widget.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitialState());

  final TextEditingController nameController = TextEditingController(
    text: 'يوسف الفيل',
  );
  final TextEditingController emailController = TextEditingController(
    text: 'yossef@example.com',
  );
  final TextEditingController birthDateController = TextEditingController(
    text: '2001-09-04',
  );
  GenderItem? selectedGender;

  void initGender(BuildContext context) {
    selectedGender ??= GenderItem(
      value: 'male',
      name: context.tr('register.maleText'),
    );
  }

  List<GenderItem> genderItems(BuildContext context) {
    return [
      GenderItem(value: 'male', name: context.tr('register.maleText')),
      GenderItem(value: 'female', name: context.tr('register.femaleText')),
    ];
  }

  void changeGender(GenderItem item) {
    selectedGender = item;
    emit(ProfileGenderChangedState());
  }

  Future<void> selectBirthDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initialDate =
        DateTime.tryParse(birthDateController.text) ?? DateTime(2001, 9, 4);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
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
    if (picked == null) return;
    birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    emit(ProfileBirthDateChangedState());
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    return super.close();
  }

  static ProfileCubit get(context) => BlocProvider.of(context);
}
