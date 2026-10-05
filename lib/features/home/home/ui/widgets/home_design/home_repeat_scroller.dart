part of '../home_design_widgets.dart';

class HomeRepeatScroller extends StatelessWidget {
  const HomeRepeatScroller({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('home.repeatService1', 'home.repeatProvider1', 'home.repeatPrice1'),
      ('home.repeatService2', 'home.repeatProvider2', 'home.repeatPrice2'),
      ('home.repeatService3', 'home.repeatProvider3', 'home.repeatPrice3'),
    ];
    return _HorizontalList(
      height: 216.h,
      children: items
          .map(
            (item) => _RepeatCard(
              titleKey: item.$1,
              metaKey: item.$2,
              priceKey: item.$3,
            ),
          )
          .toList(),
    );
  }
}

class _RepeatCard extends StatelessWidget {
  final String titleKey;
  final String metaKey;
  final String priceKey;

  const _RepeatCard({
    required this.titleKey,
    required this.metaKey,
    required this.priceKey,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      width: 318.w,
      height: 194.h,
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          SizedBox(
            height: 80.h,
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: 58.w,
                    height: 58.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      color: AppColors.greyColor50,
                    ),
                    child: const _PhotoBox(size: 58),
                  ),
                ),
                PositionedDirectional(
                  start: 70.w,
                  end: 12.w,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr(titleKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyles.font16greyColor900Weight600
                              .copyWith(height: 1.15),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          context.tr(metaKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyles.font12greyColor500W400,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(priceKey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.font12greyColor500W600.copyWith(
                                color: AppColors.greyColor700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                context.tr('home.repeatLastTime'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyles.font12greyColor500W400
                                    .copyWith(color: AppColors.greyColor400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            height: 58.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.greyColor50,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 124.w,
                  child: _PillButton(
                    label: context.tr('home.repeatButton'),
                    color: AppColors.greyColor900,
                    textColor: AppColors.whiteColor,
                    height: 34,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(child: _RepeatAvailability()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatAvailability extends StatelessWidget {
  const _RepeatAvailability();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: const BoxDecoration(
              color: AppColors.greenColor500,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 7.w),
          Flexible(
            child: Text(
              context.tr('home.repeatAvailable'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyles.font12greyColor500W400,
            ),
          ),
        ],
      ),
    );
  }
}
