part of '../home_design_widgets.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
      child: SizedBox(
        height: 62.h,
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xffD8C6A1),
                      Color(0xff5C4932),
                      Color(0xff1F1918),
                    ],
                  ),
                  boxShadow: _cardShadow(),
                ),
              ),
            ),
            PositionedDirectional(
              start: 58.w,
              end: 96.w,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _homeText(context, 'home.headerGreeting', 'أهلًا يا يوسف'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyles.font14greyColor500W400.copyWith(
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (previous, current) =>
                        previous.location != current.location,
                    builder: (context, state) {
                      final locationLabel = state.location?.displayLabel ??
                          context.tr('home.currentLocation');
                      return Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                locationLabel ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.font20greyColor900W600.copyWith(
                                  fontSize: 14.sp,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.greyColor900,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderCircleButton(
                    icon: Icons.notifications_none_rounded,
                    showBadge: true,
                  ),
                  SizedBox(width: 8.w),
                  const _HeaderCircleButton(
                    icon: Icons.favorite_border_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final IconData icon;
  final bool showBadge;

  const _HeaderCircleButton({required this.icon, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: _cardShadow(),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(icon, color: AppColors.greyColor900, size: 22.sp),
          ),
          if (showBadge)
            Positioned(
              top: 9.h,
              right: 12.w,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.errorColor100,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
