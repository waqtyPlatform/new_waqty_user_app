import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/entitlement_owner_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// رأس صفحة التفاصيل — **إيه · فين · إمتى**، بالترتيب ده.
///
/// ## «فين» نزلت مع BE-A1
///
/// الملف ده كان مكتوب فيه إن مفيش اسم مزوّد هنا وإن ده **مش نسيان**: الرد
/// مكانش فيه `provider` ولا `branch` في أي صف، فقول «باقة صالون كابتن»
/// كان هيبقى تخمين. دلوقتي الصف بيقولهم.
///
/// ⚠ **وده مش تزويق.** اللي عندها باقات في صالونين — أو في فرعين لنفس
/// الصالون بأسعار مختلفة — كانت بتفتح التفاصيل وتلاقي «باقة قص الشعر ·
/// قص شعر رجالي» وخلاص، والكارت اللي جات منه هو اللي كان بيقول المكان.
/// وده أسوأ مكان تخبّي فيه المعلومة: التفاصيل هي اللي بتتفتح **عشان
/// تتأكّد**.
///
/// الفرع بيتقال مع المزوّد لأن الحجز بيروح للفرع اللي باع، والمواعيد
/// والأسعار فرعية.
class EntitlementDetailHeaderWidget extends StatelessWidget {
  const EntitlementDetailHeaderWidget({
    required this.title,
    required this.status,
    this.subtitle,
    this.owner,
    this.purchasedAt,
    this.expiresAt,
    super.key,
  });

  final String title;
  final String? subtitle;
  final PackageStatus status;

  /// المزوّد والفرع. `null` أو باسم فاضي = **مفيش صف خالص** — قوقعة فيها
  /// حرف وسطر فاضي أوحش من غياب السطر.
  final EntitlementOwnerUiModel? owner;

  final DateTime? purchasedAt;
  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleLg,
                maxLines: 3,
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
            style: AppTextStyles.bodyMdMuted,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        if (owner != null && owner!.providerName.isNotEmpty) ...<Widget>[
          SizedBox(height: AppSpacing.s16.h),
          _OwnerRow(owner: owner!),
        ],

        SizedBox(height: AppSpacing.s16.h),

        if (purchasedAt != null)
          AppDetailRowWidget(
            label: 'اتشرت في',
            value: AppFormat.fullDate(purchasedAt!),
          ),
        if (expiresAt != null)
          AppDetailRowWidget(
            label: status == PackageStatus.expired ? 'انتهت في' : 'صالحة لحد',
            value: AppFormat.fullDate(expiresAt!),
          ),
      ],
    );
  }
}

/// **المكان** — المزوّد وتحته الفرع.
///
/// ⚠ **مش `const`** — بيرسم لون.
class _OwnerRow extends StatelessWidget {
  const _OwnerRow({required this.owner});

  final EntitlementOwnerUiModel owner;

  @override
  Widget build(BuildContext context) {
    final branch = owner.branchLabel;

    return Row(
      children: <Widget>[
        // **`entity` مش `person`** — ده محل مش أخصائي.
        EntityAvatarWidget(
          name: owner.providerName,
          size: 40,
          shape: AvatarShape.entity,
        ),
        SizedBox(width: AppSpacing.s12.w),
        // النص هو اللي بيتنازل — من غير `Expanded` الصف بيفيض عند مقياس
        // خط ١٫٣ لأن الأفاتار مقاسه ثابت ومش بيتنازل عن حاجة.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                owner.providerName,
                style: AppTextStyles.bodyMdStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (branch.isNotEmpty)
                Text(
                  branch,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
