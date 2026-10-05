import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/waqty_back_button.dart';

class HelpHeader extends StatelessWidget {
  const HelpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: const WaqtyBackButton(),
          ),
          Positioned(
            top: 8.h,
            right: 56.w,
            left: null,
            width: 230.w,
            child: Text(
              context.tr('help.title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyles.font20greyColor900W600.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
