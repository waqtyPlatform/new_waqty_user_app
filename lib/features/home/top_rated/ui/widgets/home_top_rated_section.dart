import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/top_rated/logic/top_rated_cubit.dart';
import 'package:waqty_user_application/features/home/top_rated/logic/top_rated_state.dart';
import 'package:waqty_user_application/features/home/top_rated/ui/widgets/top_rated_card.dart';

class HomeTopRatedSection extends StatelessWidget {
  final bool showDistance;

  const HomeTopRatedSection({super.key, required this.showDistance});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => TopRatedCubit(getIt())..load(),
    child: _HomeTopRatedContent(showDistance: showDistance),
  );
}

class _HomeTopRatedContent extends StatelessWidget {
  final bool showDistance;

  const _HomeTopRatedContent({required this.showDistance});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TopRatedCubit, TopRatedState>(
        builder: (context, state) {
          final cubit = context.read<TopRatedCubit>();
          if (cubit.loading && cubit.items.isEmpty) {
            return const _TopRatedSectionShimmer();
          }
          if (cubit.items.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const _TopRatedHeader(),
              SizedBox(
                height: 267.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: cubit.items.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) => TopRatedCard(
                    provider: cubit.items[index],
                    showDistance: showDistance,
                  ),
                ),
              ),
            ],
          );
        },
      );
}

class _TopRatedHeader extends StatelessWidget {
  const _TopRatedHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
    child: SizedBox(
      height: 50.h,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('home.topRatedTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font20greyColor900W600.copyWith(
                    height: 1.3,
                  ),
                ),
                Text(
                  context.tr('home.topRatedSubtitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font12greyColor500W400,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(Routes.topRatedScreen),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Text(
                context.tr('home.seeAll'),
                style: TextStyles.font12greenColor500W600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TopRatedSectionShimmer extends StatelessWidget {
  const _TopRatedSectionShimmer();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _TopRatedHeader(),
      SizedBox(
        height: 267.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (_, __) => const TopRatedShimmerCard(),
        ),
      ),
    ],
  );
}
