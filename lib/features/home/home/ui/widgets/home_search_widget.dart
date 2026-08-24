import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// شريط البحث في الهوم — **زرار مش TextField**.
///
/// القديم كان `TextField` حقيقي بـ controller بيتعمل جوه `build()` (يعني
/// أي rebuild بيمسح اللي العميل كتبه) و `onChange` كله كومنت. فالعميل كان
/// بيكتب وما يحصلش حاجة.
///
/// خليناه زرار بيودّي على شاشة بحث كاملة — ده الشكل الصح في أي marketplace،
/// لأن نتايج البحث محتاجة فلاتر وترتيب وحالة فاضية، ومكانهاش شريط في الهوم.
///
/// ## ليه [AppSearchFieldWidget] معطّل مش سطح مكتوب بالإيد
///
/// الشكل لازم يقول «ده حقل بحث» عشان الضغطة تبقى متوقّعة — والحقل المعطّل
/// بتاع الكيت **هو نفسه** اللي بيترسم في تبويب «استكشاف» لما توصله. يعني
/// الزرار هنا بيوعد بالشكل اللي هيلاقيه هناك بالحرف.
///
/// اللي اتشال: ارتفاع خام (`52.h`)، ومقاس أيقونة خام (`24.r`)، وقرارات
/// سطح واستدارة مكتوبة بالإيد كانت بتحاول تقلّد حقل الإدخال.
///
/// `AbsorbPointer` عشان الحقل نفسه مايخطفش اللمسة — الضغطة كلها للزرار.
class HomeSearchWidget extends StatelessWidget {
  final VoidCallback onTap;

  const HomeSearchWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'دوّر على صالون أو خدمة',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const AbsorbPointer(
          child: AppSearchFieldWidget(
            hintText: 'دوّر على صالون أو خدمة',
            enabled: false,
          ),
        ),
      ),
    );
  }
}
