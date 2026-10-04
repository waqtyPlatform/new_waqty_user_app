import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/apple_login_service.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/services/google_login_service.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class AccountLogoutScreen extends StatefulWidget {
  const AccountLogoutScreen({super.key});

  @override
  State<AccountLogoutScreen> createState() => _AccountLogoutScreenState();
}

class _AccountLogoutScreenState extends State<AccountLogoutScreen> {
  bool _isLoading = false;

  Future<void> _logout() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await CacheHelper.removeSecureData(ConstantKeys.saveTokenToShared);
    try {
      await getIt<GoogleLoginService>().resetSession();
    } catch (_) {}
    try {
      await getIt<AppleLoginService>().signOut();
    } catch (_) {}

    if (!mounted) return;
    context.pushNamedAndRemoveUntil(
      Routes.loginScreen,
      predicate: (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _logout,
              child: Container(
                height: 52.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.greyColor900,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.whiteColor,
                        ),
                      )
                    : Text(
                        'تسجيل الخروج',
                        style: TextStyles.font16whiteColorWeight600,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
