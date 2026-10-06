import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class SubcategoriesAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const SubcategoriesAppBar({super.key, required this.title});

  @override
  Size get preferredSize => Size.fromHeight(62.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.pageColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 64.w,
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.whiteColor,
            foregroundColor: AppColors.greyColor900,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: AppColors.greyColor900.withValues(alpha: .12),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.font24greyColor900Weight600.copyWith(
          fontSize: 20.sp,
          height: 1.2,
        ),
      ),
    );
  }
}
