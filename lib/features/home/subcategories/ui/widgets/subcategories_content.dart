import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/home/subcategories/logic/subcategories_cubit.dart';
import 'subcategories_widgets.dart';

class SubcategoriesContent extends StatelessWidget {
  final String categoryUuid;

  const SubcategoriesContent({super.key, required this.categoryUuid});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubcategoriesSearchBar(categoryUuid: categoryUuid),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.greyColor900,
            onRefresh: () => context
                .read<SubcategoriesCubit>()
                .loadSubcategories(categoryUuid: categoryUuid, force: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 32.h),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SubcategoriesList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
