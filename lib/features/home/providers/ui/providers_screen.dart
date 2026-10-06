import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/home/subcategories/ui/widgets/subcategories_app_bar.dart';
import 'widgets/providers_widgets.dart';

class ProvidersScreen extends StatelessWidget {
  final String title;
  final String? categoryUuid;
  final String? subcategoryUuid;

  const ProvidersScreen({
    super.key,
    required this.title,
    this.categoryUuid,
    this.subcategoryUuid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      appBar: SubcategoriesAppBar(title: title),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(bottom: 32.h),
          children: const [
            ProvidersSearchBar(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ProvidersFilterBar(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ProvidersGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
