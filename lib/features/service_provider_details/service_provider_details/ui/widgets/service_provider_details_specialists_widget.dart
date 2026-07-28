import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/entity_avatar_widget.dart';

/// الأخصائيين.
///
/// القديمة كانت نفس الشخص متكرر ٥ مرات، وتحت كل واحد «Sr. Barber» —
/// وده لقب متخيل، مفيش حقل زيه في الـ API أصلاً.
///
/// دلوقتي: الاسم والسعر بس، لأن دول اللي فعلاً موجودين. مفيش نبذة ومفيش
/// تقييم — الاتنين مش راجعين من أي endpoint.
class ServiceProviderDetailsSpecialistsWidget extends StatelessWidget {
  final List<EmployeeUiModel> employees;

  const ServiceProviderDetailsSpecialistsWidget({
    super.key,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    // ٧٢ صورة + ٨ + ٤ مسافات = ٨٤ ثابت، والباقي نص بيكبر مع مقياس الخط.
    final height = AppSpacing.scaledHeight(context, fixed: 84, text: 33.6);

    return SizedBox(
      height: height.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: employees.length,
        separatorBuilder: (_, __) => horizontalSpace(AppSpacing.listRowGap),
        itemBuilder: (context, index) {
          final employee = employees[index];
          return SizedBox(
            width: 88.w,
            child: Column(
              children: [
                EntityAvatarWidget(
                  name: employee.name,
                  size: 72,
                  // نصف المقاس = دايرة كاملة.
                  radius: 36,
                ),
                verticalSpace(AppSpacing.s8),
                Text(
                  employee.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionInk,
                ),
                verticalSpace(AppSpacing.s4),
                Text(
                  'من ${AppFormat.money(employee.price)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
