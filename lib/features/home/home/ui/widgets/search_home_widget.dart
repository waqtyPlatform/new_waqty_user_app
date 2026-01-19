import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/search_widget.dart';

class SearchHomeWidget extends StatelessWidget {
  const SearchHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchWidget(
      hintText: 'home.searchText'.tr(),
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      hintStyle: TextStyles.font14greyColor500W500,
      textStyle: TextStyles.font14whiteColorWeight500,
      cursorColor: AppColors.whiteColor,
      controller: TextEditingController(),
      backgroundColor: AppColors.greyColor800,
      prefixIcon: Icon(Icons.search_rounded, color: AppColors.greyColor3003),
      suffixIcon: GestureDetector(
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: SvgPicture.asset(ImageAsset.filterIcon),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.greyColor700, width: 2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.greyColor700, width: 2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      validator: (String? value) {},
      onchange: (String? value) {
        // MyAddressCubit.get(context).getMyAddress();
      },
      keyboardType: TextInputType.text,
    );
  }
}
