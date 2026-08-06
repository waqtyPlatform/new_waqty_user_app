import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/services/cache_helper.dart';
import 'package:waqty_user_application/core/utils/constant_keys.dart';

/// اختيار العميل للوضع — **بيتحفظ على الجهاز**.
///
/// الحالة هي `ThemeMode` نفسها مش كلاس ملفوف: التلات قيم دول هما كل الحالة،
/// وأي `WaqtyThemeState` كان هيبقى غلاف على enum جاهز من فلاتر.
///
/// **الافتراضي `system`.** أبلكيشن حجز بيتفتح بالليل وقت ما المحلات بتقفل،
/// والجهاز اللي عليه dark mode المفروض يلاقي الأبلكيشن مستني بنفس الوضع من
/// غير ما حد يظبط حاجة.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_restore());

  static ThemeCubit get(BuildContext context) => BlocProvider.of(context);

  /// القراءة متزامنة عن قصد — `CacheHelper.init()` بتتنادى في `main` **قبل**
  /// `runApp`، فالقيمة جاهزة. لو كانت async كان الأبلكيشن هيومض بالوضع
  /// الفاتح لإطار أو اتنين قبل ما يقلب.
  static ThemeMode _restore() {
    final saved = CacheHelper.getString(ConstantKeys.saveThemeModeToShared);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await CacheHelper.setData(ConstantKeys.saveThemeModeToShared, mode.name);
  }

  /// الإضاءة الفعلية = تفضيل العميل، ولو `system` يبقى إضاءة الجهاز.
  ///
  /// [platform] بتيجي من `MediaQuery.platformBrightnessOf` فوق `MaterialApp` —
  /// وده اللي بيخلي التبديل التلقائي وقت المغرب يشتغل من غير أي observer.
  static Brightness resolve(ThemeMode mode, Brightness platform) =>
      switch (mode) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system => platform,
      };

  /// نص عربي للاختيار — الشاشة بتعرضه، فمكانه هنا مش في الـ widget.
  static String labelOf(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'فاتح',
    ThemeMode.dark => 'غامق',
    ThemeMode.system => 'حسب الجهاز',
  };

  static IconData iconOf(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.dark => Icons.dark_mode_rounded,
    ThemeMode.system => Icons.brightness_auto_rounded,
  };
}
