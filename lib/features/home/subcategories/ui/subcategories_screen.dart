import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/home/subcategories/ui/widgets/subcategories_app_bar.dart';
import 'package:waqty_user_application/features/home/subcategories/ui/widgets/subcategories_content.dart';

class SubcategoriesScreen extends StatelessWidget {
  final String title;
  final String categoryUuid;

  const SubcategoriesScreen({super.key, required this.title, required this.categoryUuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      appBar: SubcategoriesAppBar(title: title),
      body: SubcategoriesContent(categoryUuid: categoryUuid),
    );
  }
}
