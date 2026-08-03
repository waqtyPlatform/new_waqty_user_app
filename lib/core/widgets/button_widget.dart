import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors_white_theme.dart';

class ButtonWidget extends StatelessWidget {
  final bool isLoading;

  /// لو `false` الزرار بيبقى باهت ومش بيستقبل ضغط.
  /// مكانش موجود قبل كده، فما كانش فيه طريقة نعطّل بيها زرار أصلاً.
  final bool isEnabled;
  final double? borderRadius;
  final Color? borderColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? borderWidth;
  final Color? backGroundColor;
  final Color? fourGroundColor;
  final Color? iconColor;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final IconData? icon;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const ButtonWidget({
    super.key,
    required this.isLoading,
    this.isEnabled = true,
    this.borderRadius,
    this.borderColor,
    this.iconColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.borderWidth,
    this.backGroundColor,
    this.fourGroundColor,
    this.buttonHeight,
    this.buttonWidth,
    this.icon,
    required this.buttonText,
    required this.textStyle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 20.0);

    // الزرار مايستقبلش ضغط وهو بيحمّل. قبل كده كان بيضرب onTap عادي أثناء
    // التحميل — يعني ضغطتين سريعة = حجزين.
    final canTap = !isLoading && isEnabled;

    return Opacity(
      opacity: isEnabled ? 1 : 0.45,
      child: Material(
        color: backGroundColor ?? Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: canTap ? onPressed : null,
          borderRadius: radius,
          child: Container(
            height: buttonHeight ?? 50.h,
            width: buttonWidth?.w ?? double.maxFinite,
            alignment: Alignment.center,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: horizontalPadding?.w ?? 12.w,
              vertical: verticalPadding?.h ?? 6.h,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: borderColor ?? AppColors.whiteColor,
                width: borderWidth ?? 0,
              ),
            ),
            child: isLoading == true
                ? LoadingWidget(color: fourGroundColor ?? AppColors.whiteColor)
                : (icon == null
                      ? Text(buttonText, style: textStyle)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(buttonText, style: textStyle),
                            horizontalSpace(5),
                            Icon(icon, color: iconColor, size: 18.r),
                          ],
                        )),
          ),
        ),
      ),
    );
  }
}
