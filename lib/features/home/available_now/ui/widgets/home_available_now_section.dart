import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/available_now/logic/available_now_cubit.dart';
import 'package:waqty_user_application/features/home/available_now/logic/available_now_state.dart';
import 'package:waqty_user_application/features/home/available_now/ui/widgets/available_now_card.dart';

class HomeAvailableNowSection extends StatelessWidget {
  final bool showDistance;

  const HomeAvailableNowSection({super.key, required this.showDistance});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AvailableNowCubit(getIt())..load(),
    child: _HomeAvailableNowContent(showDistance: showDistance),
  );
}

class _HomeAvailableNowContent extends StatelessWidget {
  final bool showDistance;

  const _HomeAvailableNowContent({required this.showDistance});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AvailableNowCubit, AvailableNowState>(
        builder: (context, state) {
          final cubit = context.read<AvailableNowCubit>();
          if (cubit.loading && cubit.items.isEmpty) {
            return const _AvailableNowSectionShimmer();
          }
          if (cubit.items.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const _AvailableNowHeader(),
              SizedBox(
                height: 263.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 7.h,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: cubit.items.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) => AvailableNowCard(
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

class _AvailableNowHeader extends StatelessWidget {
  const _AvailableNowHeader();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
    child: SizedBox(
      height: 50.h,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr('home.availableTodayTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font20greyColor900W600.copyWith(
                    height: 1.3,
                  ),
                ),
                Text(
                  context.tr('home.availableTodaySubtitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.font12greyColor500W400,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.availableNowScreen),
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

class _AvailableNowSectionShimmer extends StatelessWidget {
  const _AvailableNowSectionShimmer();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _AvailableNowHeader(),
      SizedBox(
        height: 263.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (_, __) => const AvailableNowShimmerCard(),
        ),
      ),
    ],
  );
}
