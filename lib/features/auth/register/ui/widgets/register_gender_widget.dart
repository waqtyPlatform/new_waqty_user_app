import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
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
      buildWhen: (previous, current) => current is OnChangeGenderState,
      builder: (context, state) {
        final cubit = RegisterCubit.get(context);

        // **`AppDropDownField<GenderItem>` مش `dynamic`.**
        //
        // النسخة القديمة كانت بتقرا `element.name` على `dynamic` — يعني أي
        // نوع مالوش `name` كان بيقع **وقت التشغيل** مش وقت التحليل.
        return AppFieldWidget(
          label: context.tr('register.genderText'),
          child: AppDropDownField<GenderItem>(
            hintText: context.tr('register.selectGenderText'),
            items: genderItems,
            value: cubit.selectedGender,
            labelOf: (item) => item.name,
            onChanged: (item) {
              if (item != null) cubit.changeGender(item);
            },
          ),
        );
      },
    );
  }
}
