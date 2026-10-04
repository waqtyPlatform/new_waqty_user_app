import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/waqty_back_button.dart';

class LanguageHeader extends StatelessWidget {
  const LanguageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
      child: Row(
        children: [
          const WaqtyBackButton(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('language.title'),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyles.font20greyColor900W600.copyWith(
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  context.tr('language.subtitle'),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: TextStyles.font12greyColor500W400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
