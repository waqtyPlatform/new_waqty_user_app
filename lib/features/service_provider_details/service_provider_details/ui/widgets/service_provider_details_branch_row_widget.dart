import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';

/// صف الفرع — **كان ناقص خالص من الصفحة القديمة**.
///
/// المواعيد والأسعار والأخصائيين كلهم بيختلفوا من فرع للتاني، ومع ذلك
/// الفرع مكانش ظاهر في أي مكان. يعني اللي عنده فرعين، العميل يحجز
/// وما يعرفش راح فين غير في التأكيد — أو يروح الفرع الغلط.
///
/// فرع واحد؟ نص عادي من غير «تغيير» — مانسألش عن حاجة مالهاش بديل.
class ServiceProviderDetailsBranchRowWidget extends StatelessWidget {
  final BranchUiModel branch;
  final bool hasMultipleBranches;
  final VoidCallback onChangeBranch;

  const ServiceProviderDetailsBranchRowWidget({
    super.key,
    required this.branch,
    required this.hasMultipleBranches,
    required this.onChangeBranch,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceWidget(
      // غاطس مش مرفوع — ده سياق بيقول «إنت فين»، مش محتوى بيتضغط.
      level: AppElevation.sunken,
      radius: AppRadius.m,
      padding: EdgeInsets.all(AppSpacing.cardPadding.r),
      child: Row(
        children: [
          // رمادي مش أخضر — الدبوس بيوصف مكان، والأخضر للأفعال.
          Icon(
            Icons.location_on_rounded,
            size: 20.r,
            color: AppSemanticColors.textSecondary,
          ),
          horizontalSpace(AppSpacing.s8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMdStrong,
                ),
                verticalSpace(AppSpacing.titleToSubtitle),
                Text(
                  branch.address.isEmpty
                      ? AppFormat.distance(branch.distanceKm)
                      : '${branch.address} · ${AppFormat.distance(branch.distanceKm)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          // الحد الأدنى للمس جاي من `textButtonTheme`.
          if (hasMultipleBranches)
            TextButton(onPressed: onChangeBranch, child: const Text('تغيير')),
        ],
      ),
    );
  }
}
