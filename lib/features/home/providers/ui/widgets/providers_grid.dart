import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/features/home/providers/data/models/provider_model.dart';
import 'package:waqty_user_application/features/home/providers/logic/providers_cubit.dart';
import 'package:waqty_user_application/features/home/providers/logic/providers_state.dart';

class ProvidersGrid extends StatelessWidget {
  const ProvidersGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProvidersCubit, ProvidersState>(
      builder: (context, state) {
        if (state is ProvidersInitialState || state is ProvidersLoadingState) {
          return const _ProvidersShimmer();
        }
        if (state is ProvidersLoadedState) {
          if (state.providers.isEmpty) return const SizedBox.shrink();
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 18.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: .68,
            ),
            itemCount: state.providers.length,
            itemBuilder: (_, index) => _ProviderCard(
              item: state.providers[index],
              rank: index + 1,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel item;
  final int rank;

  const _ProviderCard({required this.item, required this.rank});

  @override
  Widget build(BuildContext context) {
    final subtitle = [item.categoryName, item.branchName]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(' · ');
    return Container(
      padding: EdgeInsets.all(7.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.greyColor100),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: item.imageUrl == null
                      ? Container(
                          color: AppColors.greyColor50,
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColors.greyColor300,
                            size: 28.sp,
                          ),
                        )
                      : Image.network(item.imageUrl!, fit: BoxFit.cover),
                ),
                PositionedDirectional(
                  top: 8.h,
                  end: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.greyColor900,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text('#$rank', style: TextStyles.font12whiteColorWeight600),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyles.font14greyColor900Weight600,
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyles.font12greyColor4002Weight400,
          ),
          SizedBox(height: 7.h),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.star_rounded, color: AppColors.warningColor3003, size: 16.sp),
                SizedBox(width: 3.w),
                Text(item.rating.toStringAsFixed(1), style: TextStyles.font12greyColor900Weight400),
                SizedBox(width: 5.w),
                Text('${item.visitsCount} زيارة', style: TextStyles.font12greyColor4002Weight400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProvidersShimmer extends StatelessWidget {
  const _ProvidersShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 18.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: .68,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.greyColor50,
        highlightColor: AppColors.whiteColor,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.greyColor50,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}
