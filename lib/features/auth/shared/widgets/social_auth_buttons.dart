import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/services/apple_login_service.dart';
import 'package:waqty_user_application/core/services/google_login_service.dart';
import 'package:waqty_user_application/core/services/services_locator.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_constant.dart';
import 'package:waqty_user_application/core/utils/assets_manager.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/utils/styles.dart';

class SocialAuthButtons extends StatefulWidget {
  final String googleSemanticLabelKey;
  final String appleSemanticLabelKey;
  final Future<void> Function()? onGoogleTap;
  final Future<void> Function()? onAppleTap;

  const SocialAuthButtons({
    required this.googleSemanticLabelKey,
    required this.appleSemanticLabelKey,
    this.onGoogleTap,
    this.onAppleTap,
    super.key,
  });

  @override
  State<SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends State<SocialAuthButtons> {
  _SocialProvider? _loadingProvider;

  bool get _isLoading => _loadingProvider != null;

  Future<void> _signIn(_SocialProvider provider) async {
    if (_isLoading) return;
    setState(() => _loadingProvider = provider);

    try {
      final overrideTap = provider == _SocialProvider.google
          ? widget.onGoogleTap
          : widget.onAppleTap;
      if (overrideTap != null) {
        await overrideTap();
        return;
      }

      final credential = provider == _SocialProvider.google
          ? await getIt<GoogleLoginService>().signIn()
          : await getIt<AppleLoginService>().signIn();
      if (!mounted || credential == null) return;

      await _debugPrintFirebaseCredential(provider, credential);
      if (!mounted) return;
      AppConstant.toast(context.tr('socialAuth.success'), true, context);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      AppConstant.toast(
        error.message ?? context.tr('socialAuth.error'),
        false,
        context,
      );
    } catch (_) {
      if (!mounted) return;
      AppConstant.toast(context.tr('socialAuth.error'), false, context);
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  Future<void> _debugPrintFirebaseCredential(
    _SocialProvider provider,
    UserCredential credential,
  ) async {
    final user = credential.user;
    final idToken = await user?.getIdToken();
    final tokenStartEnd = idToken == null
        ? 0
        : (idToken.length < 18 ? idToken.length : 18);
    final tokenEndStart = idToken == null
        ? 0
        : (idToken.length > 12 ? idToken.length - 12 : 0);
    final tokenPreview = idToken == null
        ? null
        : {
            'length': idToken.length,
            'startsWith': idToken.substring(0, tokenStartEnd),
            'endsWith': idToken.substring(tokenEndStart),
          };

    final data = {
      'provider': provider.name,
      'uid': user?.uid,
      'email': user?.email,
      'displayName': user?.displayName,
      'phoneNumber': user?.phoneNumber,
      'photoURL': user?.photoURL,
      'isEmailVerified': user?.emailVerified,
      'isAnonymous': user?.isAnonymous,
      'creationTime': user?.metadata.creationTime?.toIso8601String(),
      'lastSignInTime': user?.metadata.lastSignInTime?.toIso8601String(),
      'providerData': user?.providerData
          .map(
            (info) => {
              'providerId': info.providerId,
              'uid': info.uid,
              'email': info.email,
              'displayName': info.displayName,
              'phoneNumber': info.phoneNumber,
              'photoURL': info.photoURL,
            },
          )
          .toList(),
      'isNewUser': credential.additionalUserInfo?.isNewUser,
      'profile': credential.additionalUserInfo?.profile,
      'firebaseIdTokenPreview': tokenPreview,
    };

    const encoder = JsonEncoder.withIndent('  ');
    debugPrint('FIREBASE_SOCIAL_AUTH_RESULT:\n${encoder.convert(data)}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.greyColor900.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                context.tr('login.continueWithText'),
                style: TextStyles.font12greyColor500W400,
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.greyColor900.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        verticalSpace(14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialAuthButton(
              semanticLabel: context.tr(widget.googleSemanticLabelKey),
              icon: ImageAsset.googleICon,
              isLoading: _loadingProvider == _SocialProvider.google,
              onTap: () => _signIn(_SocialProvider.google),
            ),
            horizontalSpace(14),
            _SocialAuthButton(
              semanticLabel: context.tr(widget.appleSemanticLabelKey),
              icon: ImageAsset.appleIcon,
              isLoading: _loadingProvider == _SocialProvider.apple,
              onTap: () => _signIn(_SocialProvider.apple),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final String semanticLabel;
  final String icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _SocialAuthButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 56.w,
            height: 56.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.greyColor900.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyColor900.withValues(alpha: 0.06),
                  blurRadius: 14.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: isLoading
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.greenColor500,
                    ),
                  )
                : SvgPicture.asset(icon, width: 22.w, height: 22.w),
          ),
        ),
      ),
    );
  }
}

enum _SocialProvider { google, apple }
