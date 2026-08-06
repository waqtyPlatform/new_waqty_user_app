import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// ثيم الأبلكيشن — **نسخة واحدة بتتبني من الـ palette الشغّال**.
///
/// ## ليه مش `theme:` و`darkTheme:` مع بعض
///
/// `AppSemanticColors` بتقرا من palette واحد globally. لو بنينا `ThemeData`
/// اتنين في نفس اللحظة، التانية كانت هتتبني بألوان الأولى — الاتنين هيطلعوا
/// متطابقين. عشان كده `my_app.dart` **بيحسم الوضع الأول** (تفضيل العميل +
/// إضاءة النظام)، بينادي `AppSemanticColors.apply`، وبعدين بيبني ثيم واحد
/// من القيم اللي بقت شغّالة.
///
/// الـ `brightness` جوه `ColorScheme` بتتقرا من نفس المصدر، فمستحيل الثيم
/// والتوكنز يفترقوا.
ThemeData appTheme() {
  final isDark = AppSemanticColors.isDark;

  final colorScheme = ColorScheme(
    brightness: AppSemanticColors.brightness,
    primary: AppSemanticColors.accent,
    onPrimary: AppSemanticColors.textOnAccent,
    primaryContainer: AppSemanticColors.accentSoft,
    onPrimaryContainer: AppSemanticColors.accent,
    secondary: AppSemanticColors.accent,
    onSecondary: AppSemanticColors.textOnAccent,
    surface: AppSemanticColors.page,
    onSurface: AppSemanticColors.textPrimary,
    surfaceContainerHighest: AppSemanticColors.surfaceSunken,
    outline: AppSemanticColors.border,
    outlineVariant: AppSemanticColors.borderStrong,
    error: AppSemanticColors.danger,
    onError: AppSemanticColors.textOnAccent,
    errorContainer: AppSemanticColors.dangerSoft,

    // ⚠ الفخ الأهم في Material 3.
    //
    // أول ما نحط `primary` أخضر، الـ surfaceTint بياخد الأخضر تلقائيًا و**كل
    // سطح مرفوع بياخد مسحة خضرا**: الـ AppBar وقت السكرول، والـ sheets،
    // والـ dialogs. شفاف هنا بيقتلها عالميًا.
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: AppSemanticColors.brightness,
    fontFamily: 'IBMPlexSansArabic',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppSemanticColors.page,
    canvasColor: AppSemanticColors.page,
    visualDensity: VisualDensity.standard,

    // InkRipple أنعم من InkSparkle بتاعة M3 — أقرب للإحساس اللي احنا رايحينله.
    splashFactory: InkRipple.splashFactory,
    splashColor: AppSemanticColors.accent.withValues(alpha: .08),
    highlightColor: AppSemanticColors.accent.withValues(alpha: .04),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayXl,
      displayMedium: AppTextStyles.displayLg,
      headlineSmall: AppTextStyles.titleXl,
      titleLarge: AppTextStyles.titleLg,
      titleMedium: AppTextStyles.sectionHeader,
      titleSmall: AppTextStyles.cardTitle,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.bodyMd,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.label,
      labelMedium: AppTextStyles.fieldLabel,
      labelSmall: AppTextStyles.overline,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppSemanticColors.page,
      foregroundColor: AppSemanticColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.sectionHeader,
      iconTheme: IconThemeData(
        color: AppSemanticColors.textPrimary,
        size: 24.r,
      ),
      // بعض رومات الأجهزة بتخفي أيقونات شريط الحالة من غير السطر ده.
      // **بتنقلب مع الوضع** — أيقونات سودا على شريط أسود بتختفي.
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppSemanticColors.surfaceRaised,
      modalBackgroundColor: AppSemanticColors.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      elevation: 0,
      modalElevation: 0,
      showDragHandle: true,
      dragHandleColor: AppSemanticColors.borderStrong,
      dragHandleSize: Size(40.r, 4.r),
      clipBehavior: Clip.antiAlias,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppSemanticColors.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
      titleTextStyle: AppTextStyles.titleLg,
      contentTextStyle: AppTextStyles.bodyMd,
    ),

    // ── الحقول ──────────────────────────────────────────────────────────
    //
    // من الـ DNA: `Rounded 12px border-radius, 1px light gray border, white
    // fill, 48px height`.
    //
    // كانت **غاطسة من غير حد** (`surfaceSunken` + `BorderSide.none`). الشكل
    // ده بيقرا «كروم» — نفس لغة شريط البحث والشيب غير المختار — والفورم
    // المفروض تقرا «اكتب هنا». الحد + السطح المرفوع بيقولوا كده.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppSemanticColors.surfaceRaised,
      hintStyle: AppTextStyles.bodyMd.copyWith(
        color: AppSemanticColors.textTertiary,
      ),
      labelStyle: AppTextStyles.fieldLabel,
      floatingLabelStyle: AppTextStyles.fieldLabel.copyWith(
        color: AppSemanticColors.accent,
      ),
      errorStyle: AppTextStyles.caption.copyWith(
        color: AppSemanticColors.danger,
      ),
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s16.w,
        vertical: 14.h,
      ),
      border: _fieldBorder(AppSemanticColors.border),
      enabledBorder: _fieldBorder(AppSemanticColors.border),
      disabledBorder: _fieldBorder(AppSemanticColors.border),
      focusedBorder: _fieldBorder(AppSemanticColors.accent, width: 1.5),
      errorBorder: _fieldBorder(AppSemanticColors.danger, width: 1.5),
      focusedErrorBorder: _fieldBorder(AppSemanticColors.danger, width: 1.5),
    ),

    dividerTheme: DividerThemeData(
      color: AppSemanticColors.border,
      thickness: 1,
      space: 1,
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppSemanticColors.accent,
        textStyle: AppTextStyles.label,
        // كل زرار نصي بياخد الحد الأدنى للمس من هنا.
        minimumSize: Size(0, AppSpacing.touchTarget.r),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rS),
      ),
    ),

    // ثانوي في الـ DNA: حد `1.5px` باللمسة، ملء شفاف، **نفس استدارة الأساسي**
    // مش stadium. الاتنين لازم يقروا كزرارين من نفس العيلة.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppSemanticColors.accent,
        textStyle: AppTextStyles.button.copyWith(
          color: AppSemanticColors.accent,
        ),
        side: BorderSide(color: AppSemanticColors.accent, width: 1.5.r),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rS),
        // ⚠ **الحد الأدنى للعرض صفر مش `double.infinity`.**
        //
        // الزرار الثانوي مش دايمًا كامل العرض — أوضح مثال زرار «احجز» جنب
        // كل خدمة في صفحة المحل، وهو جوه `Row`. الـ `infinity` جوه محور
        // غير محدود بيدي `BoxConstraints forces an infinite width`
        // و**الصفحة كلها بتقع**.
        //
        // اللي عايز عرض كامل بياخده من `AppButtonWidget` (بيحدد عرضه بنفسه)
        // أو بـ `SizedBox(width: double.infinity)` في مكان الاستدعاء.
        minimumSize: Size(0, AppSpacing.touchTarget.r),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.s16.w,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppSemanticColors.accent,
        foregroundColor: AppSemanticColors.textOnAccent,
        disabledBackgroundColor: AppSemanticColors.borderStrong,
        disabledForegroundColor: AppSemanticColors.textTertiary,
        textStyle: AppTextStyles.button,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rS),
        minimumSize: Size(double.infinity, 52.h),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppSemanticColors.textPrimary,
        iconSize: 22.r,
        minimumSize: Size(AppSpacing.touchTarget.r, AppSpacing.touchTarget.r),
      ),
    ),

    iconTheme: IconThemeData(
      color: AppSemanticColors.textSecondary,
      size: 20.r,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppSemanticColors.accent,
      linearTrackColor: AppSemanticColors.border,
      refreshBackgroundColor: AppSemanticColors.surfaceRaised,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppSemanticColors.surfaceInverse,
      contentTextStyle: AppTextStyles.bodyMd.copyWith(
        color: AppSemanticColors.textOnInverse,
      ),
      actionTextColor: AppSemanticColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rS),
      insetPadding: EdgeInsets.all(AppSpacing.s16.w),
      elevation: 0,
    ),

    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.zero,
      titleTextStyle: AppTextStyles.bodyMdStrong,
      subtitleTextStyle: AppTextStyles.caption,
      horizontalTitleGap: AppSpacing.s12.w,
      iconColor: AppSemanticColors.textSecondary,
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppSemanticColors.accent,
      selectionColor: AppSemanticColors.accentSoft,
      selectionHandleColor: AppSemanticColors.accent,
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppSemanticColors.accent
            : Colors.transparent,
      ),
      checkColor: WidgetStatePropertyAll(AppSemanticColors.textOnAccent),
      side: BorderSide(color: AppSemanticColors.borderStrong, width: 1.5.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs.r / 2),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppSemanticColors.accent
            : AppSemanticColors.borderStrong,
      ),
    ),

    // من الـ DNA: `Toggle switches use amber fill` — عندنا اللمسة الخضرا،
    // ونفس المبدأ: حتى الحركة الصغيرة بتفضل على لون البراند.
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppSemanticColors.textOnAccent
            : AppSemanticColors.surfaceRaised,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppSemanticColors.accent
            : AppSemanticColors.borderStrong,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),

    // نثبّتها عشان ماتتغيّرش لوحدها مع أي ترقية لفلاتر.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: AppRadius.rS,
      borderSide: BorderSide(color: color, width: width.r),
    );
