import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/account/language/data/models/language_option_model.dart';

class LanguageOptionCard extends StatelessWidget {
  final LanguageOptionModel option;
  final bool selected;
  final VoidCallback onTap;

  const LanguageOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenColor505 : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? AppColors.greenColor500 : Colors.transparent,
            width: selected ? 1.2 : 0,
          ),
        ),
        child: Row(children: _children),
      ),
    );
  }

  List<Widget> get _children {
    final isArabicOption = option.languageCode == 'ar';
    final marker = _RadioMarker(selected: selected);
    final content = Expanded(
      child: Column(
        crossAxisAlignment: isArabicOption
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            option.title,
            textAlign: isArabicOption ? TextAlign.right : TextAlign.left,
            style:
                (selected
                        ? TextStyles.font16greyColor900Weight600
                        : TextStyles.font16greyColor900Weight400)
                    .copyWith(height: 1.3),
          ),
          SizedBox(height: 2.h),
          Text(
            option.subtitle,
            textAlign: isArabicOption ? TextAlign.right : TextAlign.left,
            style: TextStyles.font12greyColor500W400,
          ),
        ],
      ),
    );
    final label = SizedBox(
      width: 62.w,
      child: Text(
        option.label,
        textAlign: isArabicOption ? TextAlign.left : TextAlign.right,
        style: TextStyles.font12greyColor500W600.copyWith(
          fontFamily: 'IBMPlexSansArabic',
        ),
      ),
    );

    if (isArabicOption) {
      return [
        marker,
        SizedBox(width: 12.w),
        label,
        SizedBox(width: 12.w),
        content,
      ];
    }

    return [
      marker,
      SizedBox(width: 12.w),
      content,
      SizedBox(width: 12.w),
      label,
    ];
  }
}

class _RadioMarker extends StatelessWidget {
  final bool selected;

  const _RadioMarker({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: selected ? AppColors.greenColor500 : AppColors.whiteColor,
        shape: BoxShape.circle,
        border: selected
            ? null
            : Border.all(color: AppColors.greyColor200, width: 1.5),
      ),
      child: selected
          ? Icon(Icons.check_rounded, color: AppColors.whiteColor, size: 14.sp)
          : null,
    );
  }
}
