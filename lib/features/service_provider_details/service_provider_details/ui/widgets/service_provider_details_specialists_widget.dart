import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

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
    //
    // النص **٣٤٫٥ مش ٣٣٫٦**: سطرين × ١٢×١٫٤٠ = ٣٣٫٦ حسابيًا، وفلاتر بيقرّب
    // ارتفاع السطر لأعلى وقت التشكيل فبيطلع أكبر بكسر بكسل — والكسر ده كان
    // بيفيض عند مقياس خط ١٫٣.
    final height = AppSpacing.scaledHeight(context, fixed: 84, text: 34.5);

    return SizedBox(
      height: height.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: employees.length,
        separatorBuilder: (_, __) => horizontalSpace(AppSpacing.listRowGap),
        itemBuilder: (context, index) {
          final employee = employees[index];
          return SizedBox(
            // **٩٦ مش ٨٨.** «من ٢٥٠ ج.م» مكانش داخل على ٨٨، وسطر السعر كان
            // **بيتلف لسطرين** — وده اللي كان بيفيّض العمود ١٧ بكسل.
            width: 96.w,
            child: Column(
              children: [
                // دايرة — شبكة الأخصائيين في الـ DNA أفاتارات دائرية ٥٦–٦٤.
                // الـ ٧٢ عندنا أوسع شوية عشان الحرف البديل هو اللوجو.
                EntityAvatarWidget(
                  name: employee.name,
                  size: 72,
                  shape: AvatarShape.person,
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
                // `maxLines: 1` مفروض صراحة — من غيره السطر بيتلف والعمود
                // بيفيض، والارتفاع محسوب على سطر واحد.
                Text(
                  'من ${AppFormat.money(employee.price)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
