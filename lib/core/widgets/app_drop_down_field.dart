import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors_white_theme.dart';
import '../utils/styles.dart';

class AppDropDownField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  final String hintText;
  final List<dynamic> items;

  final Widget? suffixIcon;
  final Color? backgroundColor;
  final bool? autofocus;
  final Widget? prefixIcon;
  final Function(dynamic) onChanged;
  final Function() onTap;
  final Function() onTapOutside;

  const AppDropDownField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.inputTextStyle,
    this.hintStyle,
    this.textStyle,
    this.textAlign,
    required this.hintText,
    required this.items,
    this.suffixIcon,
    this.backgroundColor,
    this.prefixIcon,
    required this.onChanged,
    required this.onTap,
    required this.onTapOutside,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        onTapOutside();
      },
      child: DropdownButtonFormField<dynamic>(
        autofocus: autofocus!,
        dropdownColor: AppColors.whiteColor,

        items: items.map((dynamic element) {
          return DropdownMenuItem<dynamic>(
            value: element,
            child: Text(
              element.name,
              style: textStyle ?? AppTextStyles.bodyLg,
            ),
          );
        }).toList(),
        menuMaxHeight: 300.h,
        onChanged: (dynamic item) {
          onChanged(item!);
        },
        isExpanded: true,
        decoration: InputDecoration(
          isDense: true,

          contentPadding:
              contentPadding ??
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          focusedBorder:
              focusedBorder ??
              OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.greyColor200,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(AppRadius.l.r),
              ),
          enabledBorder:
              enabledBorder ??
              OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.greyColor200,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(AppRadius.l.r),
              ),
          errorBorder:
              errorBorder ??
              OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.errorColor100,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(AppRadius.l.r),
              ),
          focusedErrorBorder:
              focusedErrorBorder ??
              OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.errorColor100,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(AppRadius.l.r),
              ),
          hintStyle: hintStyle ?? AppTextStyles.bodyLg,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          fillColor: backgroundColor ?? AppColors.whiteColor,
          filled: true,
        ),

        style: textStyle ?? AppTextStyles.bodyLg,
        onTap: () {
          onTap();
        },
      ),
    );
  }
}
