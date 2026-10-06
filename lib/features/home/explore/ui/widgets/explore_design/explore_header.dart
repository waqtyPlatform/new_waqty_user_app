part of '../explore_design_widgets.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.tr('explore.title');
    final titleBlock = Expanded(
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current) => previous.location != current.location,
        builder: (context, state) {
          final location = state.location?.label ?? state.location?.city?.name;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyles.font24greyColor900Weight600.copyWith(
                  letterSpacing: 0,
                  height: 1.22,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                location ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyles.font12greyColor500W400,
              ),
            ],
          );
        },
      ),
    );

    final locationButton = _ExploreCircleIcon(
      icon: Icons.location_on_outlined,
      background: AppColors.whiteColor,
      iconColor: AppColors.greyColor900,
      size: 56,
      iconSize: 28,
      shadow: true,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 6.h),
      child: Row(
        children: [
          titleBlock,
          SizedBox(width: 12.w),
          locationButton,
        ],
      ),
    );
  }
}
