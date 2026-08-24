import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

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
                  shape: AvatarShape.person,
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
    // **[AppChoiceRowWidget] راديو مش `ListTile` بعلامة صح.**
    //
    // اختيار واحد من عدة — والراديو بيقول الاتنين: فيه اختيارات تانية،
    // وده الشغّال. واتشال معاه لوح «أي أخصائي» المكتوب بالإيد (دايرة
    // ٤٠ بأيقونة ٢٠) — بقى `trailing` بأفاتار أو أيقونة على نفس المقاس.
    AppSheetWidget.show<EmployeeUiModel>(
      context,
      title: 'اختار الأخصائي',
      content: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final employee in employees)
              AppChoiceRowWidget(
                title: employee.name,
                subtitle: employee.isAnyAvailable
                    ? 'أوسع اختيار مواعيد'
                    : 'من ${AppFormat.money(employee.price)}',
                selected: employee.uuid == selectedEmployee.uuid,
                style: AppChoiceStyle.radio,
                trailing: employee.isAnyAvailable
                    ? Icon(
                        Icons.groups_outlined,
                        size: 24.r,
                        color: AppSemanticColors.textSecondary,
                      )
                    : EntityAvatarWidget(
                        name: employee.name,
                        size: 32,
                        shape: AvatarShape.person,
                      ),
                onTap: () => Navigator.of(sheetContext).pop(employee),
              ),
          ],
        ),
      ),
      actions: (_) => const [],
    ).then((employee) {
      if (employee != null) onEmployeeSelected(employee);
    });
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
                // حلقة بلون الكارت اللي تحت الأفاتارات المتراكبة — بتفصلهم
                // عن بعض. لازم تبقى لون **السطح** مش أبيض ثابت.
                border: Border.all(
                  color: AppSemanticColors.surfaceRaised,
                  width: 1.5.r,
                ),
              ),
              child: EntityAvatarWidget(
                name: shown[index].name,
                size: 32,
                shape: AvatarShape.person,
              ),
            ),
          );
        }),
      ),
    );
  }
}
