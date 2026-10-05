import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/waqty_back_button.dart';

class HelpHeader extends StatelessWidget {
  const HelpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return SizedBox(
      height: 44.h,
      child: Stack(
        children: [
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: const WaqtyBackButton(),
          ),
          Positioned(
            top: 8.h,
            right: isArabic ? 56.w : null,
            left: isArabic ? null : 56.w,
            width: 230.w,
            child: Text(
              context.tr('help.title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyles.font20greyColor900W600.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
