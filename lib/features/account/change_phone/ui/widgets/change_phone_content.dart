import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/change_phone/logic/change_phone_cubit.dart';
import 'package:waqty_user_application/features/account/change_phone/ui/widgets/change_phone_field.dart';
import 'package:waqty_user_application/features/account/change_phone/ui/widgets/change_phone_warning.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';

class ChangePhoneContent extends StatelessWidget {
  const ChangePhoneContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ChangePhoneCubit.get(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AccountFlowHeader(titleKey: 'changePhone.title'),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AccountFlowLabel(textKey: 'changePhone.currentPhoneLabel'),
              ChangePhoneField(
                controller: cubit.currentPhoneController,
                readOnly: true,
                showCountryCode: false,
                leading: const AccountVerifiedBadge(),
              ),
              SizedBox(height: 12.h),
              const AccountFlowLabel(textKey: 'changePhone.newPhoneLabel'),
              ChangePhoneField(
                controller: cubit.newPhoneController,
                highlighted: true,
                onCountryChanged: cubit.changeNewCountryCode,
              ),
              SizedBox(height: 6.h),
              Text(
                context.tr('changePhone.newPhoneHint'),
                textAlign: TextAlign.start,
                style: TextStyles.font12greyColor500W400.copyWith(height: 1.65),
              ),
              SizedBox(height: 12.h),
              const ChangePhoneWarning(),
            ],
          ),
        ),
      ],
    );
  }
}
