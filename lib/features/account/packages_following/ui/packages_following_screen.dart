import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/account/packages_following/ui/widgets/packages_following_content.dart';

class PackagesFollowingScreen extends StatelessWidget {
  const PackagesFollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.pageColor,
      body: SafeArea(child: PackagesFollowingContent()),
    );
  }
}
