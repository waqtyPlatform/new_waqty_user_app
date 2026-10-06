import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/cached_network_image.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/features/home/subcategories/data/models/subcategory_model.dart';
import 'package:waqty_user_application/features/home/subcategories/logic/subcategories_cubit.dart';
import 'package:waqty_user_application/features/home/subcategories/logic/subcategories_state.dart';

class SubcategoriesList extends StatelessWidget {
  const SubcategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubcategoriesCubit, SubcategoriesState>(
      builder: (context, state) {
        if (state is SubcategoriesInitialState ||
            state is SubcategoriesLoadingState) {
          return const _SubcategoriesShimmer();
        }
        if (state is SubcategoriesLoadedState) {
          if (state.subcategories.isEmpty) return const SizedBox.shrink();
          return _SubcategoriesList(items: state.subcategories);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SubcategoriesList extends StatelessWidget {
  final List<SubcategoryModel> items;

  const _SubcategoriesList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          _SubcategoryRow(item: items[index], showDivider: index != items.length - 1),
      ],
    );
  }
}

class _SubcategoryRow extends StatelessWidget {
  final SubcategoryModel item;
  final bool showDivider;

  const _SubcategoryRow({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          Routes.providersScreen,
          arguments: {
            'subcategory_uuid': item.uuid,
            'title': item.name,
          },
        ),
        splashColor: AppColors.greyColor50,
        child: Container(
          constraints: BoxConstraints(minHeight: 76.h),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: showDivider
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.greyColor100.withValues(alpha: .45),
                      width: .8,
                    ),
                  ),
                )
              : null,
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              SizedBox(
                width: 56.w,
                height: 56.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyColor25,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.greyColor100.withValues(alpha: .7),
                    ),
                  ),
                  child: item.iconUrl == null
                      ? Icon(
                          Icons.image_outlined,
                          color: AppColors.greyColor300,
                          size: 24.sp,
                        )
                      : CachedNetworkImageWidget(
                          imgUrl: item.iconUrl!,
                          radius: BorderRadius.circular(999.r),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyles.font14greyColor900Weight500,
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.greyColor300,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubcategoriesShimmer extends StatelessWidget {
  const _SubcategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.greyColor50,
      highlightColor: AppColors.whiteColor,
      child: Column(
        children: List.generate(
          6,
          (_) => Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.greyColor50,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 120.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.greyColor50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
