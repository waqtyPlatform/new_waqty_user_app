import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// شريط البحث الحقيقي.
///
/// الـ controller جاي من الـ Cubit مش متعمل هنا — القديم كان بيتعمل جوه
/// `build()` فأي rebuild كان بيمسح اللي العميل كتبه.
///
/// ## بقى [AppSearchFieldWidget]
///
/// اتشال ٤٥ سطر `InputDecoration` مكتوب بالإيد: تلات `OutlineInputBorder`،
/// وحشوة رأسية خام (`14.h`)، وسُمك حد خام (`1.5.r`)، ومقاسين أيقونة
/// (`22.r` و`20.r`).
///
/// **الحقل بقى مرفوع مش غاطس.** ده اللي `inputDecorationTheme` بيقوله لكل
/// حقول الأبلكيشن، والبحث كان الاستثناء الوحيد — يعني كان أول حقل العميل
/// يشوفه في تبويب «استكشاف» شكله مختلف عن كل حقل تاني.
class ProvidersListSearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool autofocus;
  final VoidCallback onChanged;
  final VoidCallback onClear;

  const ProvidersListSearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppSearchFieldWidget(
      hintText: 'دوّر على صالون أو منطقة',
      controller: controller,
      autofocus: autofocus,
      onChanged: (_) => onChanged(),
      onClear: onClear,
    );
  }
}
