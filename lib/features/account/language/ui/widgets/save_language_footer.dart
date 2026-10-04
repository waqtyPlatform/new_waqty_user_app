import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/account/language/logic/language_cubit.dart';

class SaveLanguageFooter extends StatelessWidget {
  final LanguageCubit cubit;

  const SaveLanguageFooter({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 26.h),
      decoration: BoxDecoration(
        color: AppColors.pageColor.withValues(alpha: 0.94),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ButtonWidget(
        isLoading: false,
        borderRadius: 999,
        buttonHeight: 52.h,
        buttonText: context.tr('language.saveButton'),
        backGroundColor: AppColors.greyColor900,
        borderColor: AppColors.greyColor900,
        textStyle: TextStyles.font16whiteColorWeight600,
        onPressed: cubit.markSaved,
      ),
    );
  }
}
