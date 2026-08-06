import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/themes/theme_cubit.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_menu_item_widget.dart';

/// صف «المظهر» في قايمة الحساب.
///
/// ## ليه sheet بتلات اختيارات مش سويتش
///
/// السويتش بيعرف حالتين، والحالات هنا **تلاتة**: فاتح، غامق، و«حسب الجهاز».
/// والتالتة هي الافتراضية وهي اللي معظم الناس هتسيبها — يعني السويتش كان
/// هيضطر يمثّل الحالة الافتراضية كواحدة من التانيتين ويكدب.
///
/// ## تنبيه: التبديل بيرجّع الشاشة للرئيسية
///
/// `MaterialApp` عندها مفتاح على الإضاءة (شوف `my_app.dart`)، فتغيير الوضع
/// بيبني الشجرة من الأول. مكتوب هنا عشان اللي هيقرا الكود مايفتكرش إنه باج.
class AccountThemeItemWidget extends StatelessWidget {
  const AccountThemeItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => AccountMenuItemWidget(
        icon: ThemeCubit.iconOf(mode),
        label: 'المظهر',
        trailingText: ThemeCubit.labelOf(mode),
        onTap: () => _showSheet(context, mode),
      ),
    );
  }

  void _showSheet(BuildContext context, ThemeMode current) {
    // الـ cubit بيتقرا هنا مش جوه الـ builder: الـ sheet بيتبني في شجرة
    // `Navigator` تانية، فـ `context` جواه **مش تحت الـ BlocProvider**.
    final cubit = ThemeCubit.get(context);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.pageGutter.w,
          end: AppSpacing.pageGutter.w,
          top: AppSpacing.s8.h,
          bottom: AppSpacing.s16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المظهر', style: AppTextStyles.sectionHeader),
            verticalSpace(AppSpacing.s8),
            ...ThemeMode.values.map(
              (mode) => ListTile(
                leading: Icon(
                  ThemeCubit.iconOf(mode),
                  color: mode == current
                      ? AppSemanticColors.accent
                      : AppSemanticColors.textSecondary,
                ),
                title: Text(ThemeCubit.labelOf(mode)),
                trailing: mode == current
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: AppSemanticColors.accent,
                      )
                    : null,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.setMode(mode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
