import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/subcategories/ui/widgets/subcategories_app_bar.dart';
import 'package:waqty_user_application/features/home/top_rated/logic/top_rated_cubit.dart';
import 'package:waqty_user_application/features/home/top_rated/logic/top_rated_state.dart';
import 'package:waqty_user_application/features/home/top_rated/ui/widgets/top_rated_card.dart';

class TopRatedScreen extends StatelessWidget {
  const TopRatedScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.pageColor,
    appBar: SubcategoriesAppBar(title: context.tr('home.topRatedTitle')),
    body: SafeArea(
      child: BlocBuilder<TopRatedCubit, TopRatedState>(
        builder: (context, state) {
          final cubit = context.read<TopRatedCubit>();
          if (cubit.loading && cubit.items.isEmpty) {
            return const _TopRatedPageShimmer();
          }
          if (state is TopRatedErrorState && cubit.items.isEmpty) {
            return _TopRatedMessage(
              message: state.message.trim().isEmpty
                  ? context.tr('home.topRatedLoadError')
                  : state.message,
              actionLabel: context.tr('home.availableNowRetry'),
              onAction: cubit.load,
            );
          }
          if (cubit.items.isEmpty) {
            return _TopRatedMessage(message: context.tr('home.topRatedEmpty'));
          }
          return RefreshIndicator(
            color: AppColors.greyColor900,
            onRefresh: cubit.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 320) cubit.loadMore();
                return false;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 14.h,
                        mainAxisExtent: 245.h,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TopRatedCard(
                          provider: cubit.items[index],
                          showDistance: true,
                          width: double.infinity,
                        ),
                        childCount: cubit.items.length,
                      ),
                    ),
                  ),
                  if (cubit.loadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 28.h),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.greyColor900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _TopRatedMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _TopRatedMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 120.h),
    children: [
      Icon(
        Icons.star_outline_rounded,
        size: 44.sp,
        color: AppColors.greyColor300,
      ),
      SizedBox(height: 14.h),
      Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyles.font16greyColor900Weight600,
      ),
      if (actionLabel != null && onAction != null) ...[
        SizedBox(height: 18.h),
        Center(
          child: FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.greyColor900,
              foregroundColor: AppColors.whiteColor,
            ),
            child: Text(actionLabel!),
          ),
        ),
      ],
    ],
  );
}

class _TopRatedPageShimmer extends StatelessWidget {
  const _TopRatedPageShimmer();

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 14.h,
      mainAxisExtent: 245.h,
    ),
    itemCount: 6,
    itemBuilder: (_, __) => const TopRatedShimmerCard(width: double.infinity),
  );
}
