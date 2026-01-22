import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';

class ServiceProviderDetailsTopBarWidget extends StatelessWidget {
  const ServiceProviderDetailsTopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: SizedBox(
        height: 350.h,
        width: double.infinity,
        child: Image.asset(ImageAsset.t4, fit: BoxFit.fill),
      ),
    );
  }
}
