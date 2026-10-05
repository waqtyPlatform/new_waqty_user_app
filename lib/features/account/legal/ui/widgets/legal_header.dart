import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/waqty_back_button.dart';

class LegalHeader extends StatelessWidget {
  const LegalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: const WaqtyBackButton(),
          ),
          Positioned(
            top: 0,
            right: 52.w,
            left: null,
            width: 242.w,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      context.tr('legal.title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyles.font20greyColor900W600.copyWith(
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      context.tr('legal.updatedAt'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
