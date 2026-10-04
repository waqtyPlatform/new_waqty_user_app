import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/shared/widgets/account_flow_widgets.dart';
import 'package:waqty_user_application/features/auth/register/ui/widgets/register_gender_widget.dart';

class ProfileGenderField extends StatelessWidget {
  final String labelKey;
  final GenderItem value;
  final List<GenderItem> items;
  final ValueChanged<GenderItem> onChanged;

  const ProfileGenderField({
    super.key,
    required this.labelKey,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountFlowLabel(textKey: labelKey),
        DropdownButtonFormField<GenderItem>(
          initialValue: value,
          dropdownColor: AppColors.whiteColor,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<GenderItem>(
              value: item,
              child: Text(
                item.name,
                style: TextStyles.font16greyColor900Weight400.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (item) {
            if (item != null) onChanged(item);
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 17.h,
              horizontal: 14.w,
            ),
            fillColor: AppColors.whiteColor,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.greyColor900.withValues(alpha: 0.10),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(18.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.greenColor500,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(18.r),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
              borderRadius: BorderRadius.circular(18.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.errorColor100, width: 1),
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
          style: TextStyles.font16greyColor900Weight400.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
