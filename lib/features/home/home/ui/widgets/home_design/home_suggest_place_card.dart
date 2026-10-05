part of '../home_design_widgets.dart';

class HomeSuggestPlaceCard extends StatelessWidget {
  const HomeSuggestPlaceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionPadding(
      top: 20,
      child: _WhiteCard(
        height: 91.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SizedBox(
                width: 88.w,
                height: 38.h,
                child: _PillButton(
                  label: context.tr('home.suggestButton'),
                  color: AppColors.greenColor505,
                  textColor: AppColors.greenColor600,
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              end: 100.w,
              top: 0,
              bottom: 0,
              child: _TextBlock(
                titleKey: 'home.suggestTitle',
                subtitleKey: 'home.suggestSubtitle',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
