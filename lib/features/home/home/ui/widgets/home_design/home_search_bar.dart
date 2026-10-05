part of '../home_design_widgets.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: _deepShadow(),
        ),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _RoundIcon(
                color: AppColors.greenColor505,
                icon: Icons.search_rounded,
                iconColor: AppColors.greenColor600,
              ),
            ),
            Positioned.fill(
              left: 46.w,
              right: 46.w,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.tr('home.searchPlaceholder'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyles.font16greyColor500Weight400,
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _RoundIcon(
                color: AppColors.sunkenColor,
                icon: Icons.tune_rounded,
                iconColor: AppColors.greyColor900,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
