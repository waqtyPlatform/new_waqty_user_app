import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/config/themes/theme_cubit.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// صف «المظهر» في قايمة الحساب.
///
/// ## ليه sheet بتلات اختيارات مش سويتش
///
/// السويتش بيعرف حالتين، والحالات هنا **تلاتة**: فاتح، غامق، و«حسب الجهاز».
/// والتالتة هي الافتراضية وهي اللي معظم الناس هتسيبها — يعني السويتش كان
/// هيضطر يمثّل الحالة الافتراضية كواحدة من التانيتين ويكدب.
///
/// (والكيت شايل `AppToggleWidget` فعلاً — بس هو حالتين، فمش هو.)
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
      builder: (context, mode) => AppMenuRowWidget(
        icon: ThemeCubit.iconOf(mode),
        title: 'المظهر',
        subtitle: ThemeCubit.labelOf(mode),
        onTap: () => _showSheet(context, mode),
      ),
    );
  }

  void _showSheet(BuildContext context, ThemeMode current) {
    // الـ cubit بيتقرا هنا مش جوه الـ builder: الـ sheet بيتبني في شجرة
    // `Navigator` تانية، فـ `context` جواه **مش تحت الـ BlocProvider**.
    final cubit = ThemeCubit.get(context);

    // **`AppSheetWidget.show` بيرجّع الاختيار، والشاشة هي اللي بتنفّذه.**
    //
    // الـ sheet مابيناديش `setMode` من جواه — ده مبدأ الكيت: اللي بينده
    // هو اللي بيقفل وهو اللي بيتصرّف. فالترتيب هنا مضمون: الورقة بتقفل
    // الأول، وبعدين الوضع بيتغيّر ويرمي الشجرة. لو اتعكس، الـ `Navigator`
    // اللي الورقة قاعدة فيه بيتحذف وهي لسه مفتوحة.
    AppSheetWidget.show<ThemeMode>(
      context,
      title: 'المظهر',
      // `content` بيتبني **قبل** ما الورقة تتفتح، فمالوش `sheetContext`.
      // الـ `Builder` بيدّي واحد جوه شجرة الورقة — من غيره `Navigator.of`
      // بتشتغل صح بالصدفة (بتلاقي نفس الـ Navigator) وبتكسر أول ما حاجة
      // تانية تتحط فوق الورقة.
      content: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              AppChoiceRowWidget(
                title: ThemeCubit.labelOf(mode),
                selected: mode == current,
                style: AppChoiceStyle.radio,
                onTap: () => Navigator.of(sheetContext).pop(mode),
              ),
          ],
        ),
      ),
      // الاختيار **هو** الفعل — زرار «تأكيد» تحت تلات اختيارات بيزوّد
      // ضغطة على قرار راجع في ضغطة.
      actions: (_) => const [],
    ).then((picked) {
      if (picked != null) cubit.setMode(picked);
    });
  }
}
