import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_cubit.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/ui/widgets/entitlements_body_widget.dart';

/// **«باقاتي ومتابعاتي»** كشاشة كاملة — المدخل من صف «حسابي».
///
/// المدخل الأساسي هو **التبويب التالت جوه «حجوزاتي»**؛ الشاشة دي البيت
/// الدايم اللي بيفضل موجود لو التبويب اتنقل بكرة. الاتنين بيرسموا
/// [EntitlementsBodyWidget] نفسه، فمافيش نسختين من الحالات.
///
/// الـcubit **مش بيتعمل هنا** — بييجي بـ`BlocProvider.value` من
/// `ButtonNavigationBarScreen` فوق التبويبات.
class EntitlementsScreen extends StatelessWidget {
  const EntitlementsScreen({super.key});

  /// **المدخل الوحيد للشاشة — ومقصود إنه الوحيد.**
  ///
  /// ## الباج اللي بيمنعه
  ///
  /// الشاشة بتتدفع على الـnavigator بتاع `MaterialApp`، واللي **فوق**
  /// الـproviders بتوع الـshell. يعني `EntitlementsCubit` **و**
  /// `AccountCubit` الاتنين بيخرجوا من النطاق — و[EntitlementsBodyWidget]
  /// بينده الاتنين (التاني عشان يعرف الرقم مأكّد ولا لأ في الحالة
  /// الفاضية).
  ///
  /// أول نسخة من الكود دفعت `EntitlementsCubit` بس، فالشاشة كانت
  /// **بتكسر بـ`ProviderNotFoundException`** أول ما التبويب المعروض
  /// يبقى فاضي — وهي أكتر حالة متوقعة عند الإطلاق.
  ///
  /// الدالة دي بتقرا الاتنين من `context` بتاع اللي بينده (اللي هو **جوه**
  /// الـshell) وبتمرّرهم بـ`.value`. طالما الفتح كله بيعدّي من هنا،
  /// النسيان مش ممكن.
  static Future<void> open(BuildContext context) {
    final entitlements = EntitlementsCubit.get(context);
    final account = AccountCubit.get(context);

    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<EntitlementsCubit>.value(value: entitlements),
            BlocProvider<AccountCubit>.value(value: account),
          ],
          child: const EntitlementsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSemanticColors.page,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.pageGutter.w,
              ),
              child: AppScreenHeaderWidget(
                title: 'باقاتي ومتابعاتي',
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            verticalSpace(AppSpacing.headerToContent),
            const Expanded(child: EntitlementsBodyWidget()),
          ],
        ),
      ),
    );
  }
}
