part of '../home_design_widgets.dart';

class HomeSectionHeader extends StatelessWidget {
  final String titleKey;
  final String subtitleKey;

  const HomeSectionHeader({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionTitleRow(
      title: context.tr(titleKey),
      subtitle: context.tr(subtitleKey),
      top: 20,
    );
  }
}

class HomeCategorySection extends StatelessWidget {
  final String titleKey;
  final String subtitleKey;
  final IconData icon;

  const HomeCategorySection({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionTitleRow(
      title: context.tr(titleKey),
      subtitle: context.tr(subtitleKey),
      icon: icon,
      top: 20,
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final double top;

  const _SectionTitleRow({
    required this.title,
    required this.subtitle,
    this.icon,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, top.h, 20.w, 0),
      child: SizedBox(
        height: 50.h,
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                context.tr('home.seeAll'),
                style: TextStyles.font12greenColor500W600,
              ),
            ),
            PositionedDirectional(
              start: icon == null ? 0 : 46.w,
              end: 56.w,
              top: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: TextStyles.font20greyColor900W600.copyWith(
                      height: 1.3,
                    ),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.start,
                    style: TextStyles.font12greyColor500W400,
                  ),
                ],
              ),
            ),
            if (icon != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.greenColor505,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.greenColor600, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
