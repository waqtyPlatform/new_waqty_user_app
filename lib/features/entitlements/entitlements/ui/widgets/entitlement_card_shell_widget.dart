import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **الهيكل المشترك لكروت الاستحقاق** — عنوان وحالة وانتهاء وسبب المنع.
///
/// ## ليه هيكل مشترك مع إن الكروت متعمّدة تبقى مختلفة
///
/// الاختلاف المقصود في **الجسم**: جلسات مقابل وحدات مقابل متابعة. أما
/// الإطار — العنوان، شارة «انتهت»، سطر الصلاحية، السطر اللي بيقول ليه
/// الزرار مقفول — فواحد. لو اتكرر تلات مرات، أول تغيير في نص المنع هيمشي
/// في كارت وينسى التانيين، والعميلة هتشوف سببين مختلفين لنفس المنع.
class EntitlementCardShellWidget extends StatelessWidget {
  const EntitlementCardShellWidget({
    required this.title,
    required this.status,
    required this.body,
    this.subtitle,
    this.expiresAt,
    this.expiresSoon = false,
    this.isMuted = false,
    this.blockedReason,
    this.action,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final PackageStatus status;
  final DateTime? expiresAt;
  final bool expiresSoon;

  /// الحالات النهائية بتترسم باهتة — موجودة للسجل مش للفعل.
  final bool isMuted;

  /// السطر اللي بيقول ليه مفيش زرار. `null` = مافيش منع يتقال.
  final String? blockedReason;

  /// زرار الفعل لو فيه.
  final Widget? action;

  final VoidCallback? onTap;

  /// جسم الكارت — ده اللي بيفرّق بين النوعين التلاتة.
  final List<Widget> body;

  @override
  Widget build(BuildContext context) {
    final titleColor = isMuted
        ? AppSemanticColors.textSecondary
        : AppSemanticColors.textPrimary;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.listRowGap.h),
      child: AppSurfaceWidget(
        level: AppElevation.raised,
        radius: AppRadius.l,
        padding: EdgeInsets.all(AppSpacing.cardPaddingLoose.r),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // **النص `Expanded` والشارة لأ.** الشارة كلمة واحدة ماتتقصّش،
            // واسم الباقة هو اللي بيتنازل — و`Spacer` مكانش هيكفي: عند
            // مقياس ١٫٣ كل عنصر بياخد مقاسه الطبيعي والصف بيفيض.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  // عنوان فاضي = مافيش سطر خالص. الـskeleton بيبعت `''`
                  // وبيحط مستطيله في الجسم، فلو رسمنا `Text` فاضي هيفضل
                  // سطر شبح بارتفاع بيخلي التحميل أطول من الكارت.
                  child: title.isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                          title,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: titleColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                if (status.isTerminal) ...<Widget>[
                  SizedBox(width: AppSpacing.s8.w),
                  AppPillWidget(
                    label: status.label,
                    tone: status == PackageStatus.expired
                        ? AppPillTone.danger
                        : AppPillTone.neutral,
                  ),
                ],
              ],
            ),

            if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
              SizedBox(height: AppSpacing.titleToSubtitle.h),
              Text(
                subtitle!,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: AppSpacing.s12.h),
            ...body,

            if (_expiryLine != null) ...<Widget>[
              SizedBox(height: AppSpacing.s8.h),
              Text(
                _expiryLine!,
                style: expiresSoon
                    ? AppTextStyles.caption.copyWith(
                        color: AppSemanticColors.dangerOnSoft,
                      )
                    : AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (action != null) ...<Widget>[
              SizedBox(height: AppSpacing.s16.h),
              action!,
            ],

            // **سبب المنع بيتقال، مش بيتسكت عنه.**
            //
            // زرار متعطّل من غير سبب بيخلّي العميلة تدوس عليه مرة ورا مرة
            // وتفتكر إن التطبيق باظ. والسبب الحقيقي (الفرع مش في الرد)
            // مش حاجة تتقال لها بالشكل ده — فبنقول اللي يهمها: تكلّم الفرع.
            if (blockedReason != null) ...<Widget>[
              SizedBox(height: AppSpacing.s12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16.r,
                    color: AppSemanticColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: Text(
                      blockedReason!,
                      style: AppTextStyles.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// سطر الصلاحية — **بيقول التاريخ لما ينفع، ومابيخترعش لما مايعرفش**.
  String? get _expiryLine {
    final expiry = expiresAt;
    if (expiry == null) return null;

    if (status == PackageStatus.expired) {
      return 'انتهت في ${AppFormat.fullDate(expiry)}';
    }
    if (status.isTerminal) return null;

    if (expiresSoon) {
      final days = expiry.difference(DateTime.now()).inDays;
      if (days <= 0) return 'تنتهي النهاردة';
      return 'تنتهي بعد ${AppFormat.digits(days)} أيام';
    }

    return 'صالحة لحد ${AppFormat.fullDate(expiry)}';
  }
}
