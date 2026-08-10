import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_cubit.dart';
import 'package:waqty_user_application/features/auth/register/logic/register_state.dart';

class RegisterBirthDateWidget extends StatelessWidget {
  const RegisterBirthDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) => current is OnChangeBirthDateState,
      builder: (context, state) {
        return AppFieldWidget(
          label: context.tr('register.birthDateText'),
          child: AppTextFormField(
            hintText: context.tr('register.enterBirthDateText'),
            controller: RegisterCubit.get(context).registerBirthDateController,
            // `readOnly` مش `keyboardType: none` — التانية بتمنع الكيبورد بس
            // وبتسيب العميل يلزق نص في حقل المفروض المنتقي هو اللي يملاه.
            readOnly: true,
            suffixIcon: Icon(
              Icons.calendar_today_rounded,
              color: AppSemanticColors.textTertiary,
              size: 20.r,
            ),
            onTap: () => _selectDate(context),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final cubit = RegisterCubit.get(context);
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      // **١٩٩٥ مش ١٩٠٠.** المنتقي كان بيفتح على سنة ١٩٠٠ — يعني أي حد عايز
      // يحط تاريخه لازم يلف ٩٥ سنة لورا. السنة دي أقرب لوسط عملاء الأبلكيشن.
      initialDate: DateTime(1995),
      firstDate: DateTime(1900),
      lastDate: now,
      // مفيش `Theme` مكتوب بالإيد هنا: المنتقي بياخد `colorScheme` من ثيم
      // الأبلكيشن، واللي كان مكتوب كان `ColorScheme.light` ثابت — يعني في
      // الوضع الغامق كان هيطلّع منتقي أبيض وسط أبلكيشن أسود.
      helpText: context.tr('register.birthDateText'),
    );

    if (picked == null || !context.mounted) return;

    // `yyyy-MM-dd` بالإيد مش `DateFormat` — الأبلكيشن مابيناديش
    // `initializeDateFormatting`، و`intl` بلوكال عربي بيطلّع أرقام هندية
    // والسيرفر بيرفضها.
    String two(int v) => v.toString().padLeft(2, '0');
    cubit.changeBirthDate(
      '${picked.year}-${two(picked.month)}-${two(picked.day)}',
    );
  }
}
