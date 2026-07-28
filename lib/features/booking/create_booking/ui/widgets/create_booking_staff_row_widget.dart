import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/entity_avatar_widget.dart';

/// صف الأخصائي — **صف واحد، مش شاشة لوحدها**.
///
/// اختيار الأخصائي مش خطوة مستقلة بالقصد. لما نخلّيه خطوة، بنجبر العميل
/// على تفضيل هو أصلاً ملوش، وبنقلّل المواعيد قبل ما يشوفها.
///
/// الشيت اللي بيفتح بيعرض سعر كل واحد — لأن السعر بيختلف من أخصائي
/// للتاني، والعميل لازم يعرف ده **قبل** ما يختار مش بعدين.
class CreateBookingStaffRowWidget extends StatelessWidget {
  final List<EmployeeUiModel> employees;
  final EmployeeUiModel selectedEmployee;
  final ValueChanged<EmployeeUiModel> onEmployeeSelected;

  const CreateBookingStaffRowWidget({
    super.key,
    required this.employees,
    required this.selectedEmployee,
    required this.onEmployeeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.m.r);
    final others = employees.where((e) => !e.isAnyAvailable).toList();

    return Material(
      color: AppSemanticColors.surfaceSunken,
      borderRadius: radius,
      child: InkWell(
        onTap: () => _showStaffSheet(context),
        borderRadius: radius,
        child: Container(
          height: 60.h,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              if (selectedEmployee.isAnyAvailable)
                _AvatarStack(employees: others)
              else
                EntityAvatarWidget(
                  name: selectedEmployee.name,
                  size: 36,
                  radius: 18,
                ),
              horizontalSpace(10),
              Expanded(
                child: Text(
                  selectedEmployee.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMdStrong,
                ),
              ),
              Text('تغيير', style: AppTextStyles.label),
            ],
          ),
        ),
      ),
    );
  }

  void _showStaffSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.s16.w,
          end: AppSpacing.s16.w,
          top: AppSpacing.s8.h,
          bottom: AppSpacing.s16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اختر الأخصائي', style: AppTextStyles.sectionHeader),
            verticalSpace(AppSpacing.s12),
            ...employees.map(
              (employee) => ListTile(
                leading: employee.isAnyAvailable
                    ? Container(
                        height: 40.r,
                        width: 40.r,
                        decoration: const BoxDecoration(
                          color: AppSemanticColors.surfaceSunken,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.groups_outlined,
                          size: 20.r,
                          color: AppSemanticColors.textSecondary,
                        ),
                      )
                    : EntityAvatarWidget(
                        name: employee.name,
                        size: 40,
                        radius: 20,
                      ),
                title: Text(employee.name),
                subtitle: Text(
                  employee.isAnyAvailable
                      ? 'أوسع اختيار مواعيد'
                      : 'من ${AppFormat.money(employee.price)}',
                ),
                trailing: employee.uuid == selectedEmployee.uuid
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppSemanticColors.accent,
                      )
                    : null,
                onTap: () {
                  onEmployeeSelected(employee);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<EmployeeUiModel> employees;

  const _AvatarStack({required this.employees});

  @override
  Widget build(BuildContext context) {
    final shown = employees.take(3).toList();

    return SizedBox(
      height: 36.r,
      width: (20.0 * shown.length + 16).w,
      child: Stack(
        children: List<Widget>.generate(shown.length, (index) {
          return PositionedDirectional(
            start: (index * 18).w,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.whiteColor, width: 1.5),
              ),
              child: EntityAvatarWidget(
                name: shown[index].name,
                size: 32,
                radius: 16,
              ),
            ),
          );
        }),
      ),
    );
  }
}
