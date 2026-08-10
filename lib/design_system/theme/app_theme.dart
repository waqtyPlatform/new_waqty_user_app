import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// ثيم الكيت — **نسخة واحدة بتتبني من الـ palette الشغّال**.
///
/// ## ⚠ ليه مافيش `theme:` و`darkTheme:` مع بعض
///
/// `AppSemanticColors` بتقرا من palette واحد globally. لو بنينا `ThemeData`
/// اتنين في نفس اللحظة، **التانية هتتبني بألوان الأولى** — الاتنين هيطلعوا
/// متطابقين. عشان كده اللي بيشغّل الأبلكيشن بيحسم الوضع الأول (تفضيل
/// العميل + إضاءة النظام)، بينادي `AppSemanticColors.apply`، وبعدين بيبني
/// ثيم واحد من القيم اللي بقت شغّالة.
///
/// الـ `brightness` جوه `ColorScheme` بتتقرا من نفس المصدر، فمستحيل الثيم
/// والتوكنز يفترقوا.
///
/// ## اللي الثيم ده بيصلّحه في employee-app
///
/// الـ `ThemeData` هناك **١١ سطر أغلبها معلّق**، و`useMaterial3: true`
/// شغّال — يعني كل default بتاع Material (الـ ripple، حلقة التركيز،
/// المؤشر، مقابض التحديد) بيرسم بالبنفسجي الافتراضي بتاع M3 مش بالأخضر.
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
    // أول ما نحط `primary` أخضر، الـ surfaceTint بياخد الأخضر تلقائيًا
    // و**كل سطح مرفوع بياخد مسحة خضرا**: الـ AppBar وقت السكرول، والـ
    // sheets، والـ dialogs. شفاف هنا بيقتلها عالميًا.
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

    // InkRipple أنعم من InkSparkle بتاعة M3.
    splashFactory: InkRipple.splashFactory,
    splashColor: AppSemanticColors.accent.withValues(alpha: .08),
    highlightColor: AppSemanticColors.accent.withValues(alpha: .04),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLg,
      displayMedium: AppTextStyles.titleXl,
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
      // ⚠ `AppSheetWidget` بيعتمد على ده ومابيرسمش مقبض بنفسه. لو اتقفل،
      // التلات نسخ من الـ sheet اللي اتلمّوا هيرجعوا يرسموه بالإيد.
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
    // employee-app بيكتب **٥ `OutlineInputBorder` بالإيد** في كل حقل
    // (`app_text_field.dart`)، وبيعيدهم في `app_drop_down_field.dart` و
    // `search_widget.dart`. هنا مرة واحدة، والـ widget بيبقى شكل بس.
    //
    // ⚠ **وهنا بالظبط باج DMSans بيموت.** الـ hint والنص في employee-app
    // بياخدوا `TextStyles.font16BlackColorWeight400` اللي معلن
    // `fontFamily: 'DMSans'` — خط **مش موجود في الـ pubspec ولا على
    // الديسك**. يعني كل حقل إدخال في الأبلكيشن بيرسم بخط النظام الاحتياطي.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppSemanticColors.surfaceRaised,
      hintStyle: AppTextStyles.bodyMd.copyWith(
        color: AppSemanticColors.textTertiary,
      ),
      labelStyle: AppTextStyles.fieldLabel,
      floatingLabelStyle: AppTextStyles.fieldLabel.copyWith(
        color: AppSemanticColors.accentText,
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
        // accentText مش accent — الأخضر هنا **هو النص**.
        foregroundColor: AppSemanticColors.accentText,
        textStyle: AppTextStyles.label,
        // كل زرار نصي بياخد الحد الأدنى للمس من هنا.
        minimumSize: Size(0, AppSpacing.touchTarget.r),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppSemanticColors.accentText,
        textStyle: AppTextStyles.button.copyWith(
          color: AppSemanticColors.accentText,
        ),
        side: BorderSide(color: AppSemanticColors.accent, width: 1.5.r),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
        // ⚠ **الحد الأدنى للعرض صفر مش `double.infinity`.**
        //
        // زرار جوه `Row` مع `infinity` بيدي
        // `BoxConstraints forces an infinite width` و**الشاشة كلها بتقع**.
        // اللي عايز عرض كامل بياخده من `AppButtonWidget`.
        minimumSize: Size(0, 50.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.s16.w),
      ),
    ),

    // ⚠ **الخلفية `surfaceAccentDeep` مش `accent`.**
    //
    // ده قرار D6 وهو بيقع هنا بالظبط: الزرار الأساسي **تعبئة خضرا تحتها
    // نص**. الأبيض على `accent #009354` بيدي **3.96:1** (راسب AA)، وعلى
    // `accentDeep #00693C` بيدي **6.81:1**.
    //
    // وده مش لون جديد على الهوية: زرار employee-app بيرسم تدرّج
    // `#009354 → #007341` النهاردة، يعني الأخضر الأغمق **متحطوط على
    // الزرار ده فعلًا**.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppSemanticColors.surfaceAccentDeep,
        foregroundColor: AppSemanticColors.textOnAccentDeep,
        disabledBackgroundColor: AppSemanticColors.borderStrong,
        disabledForegroundColor: AppSemanticColors.textTertiary,
        textStyle: AppTextStyles.button.copyWith(
          color: AppSemanticColors.textOnAccentDeep,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rL),
        minimumSize: Size(0, 50.h),
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
      borderRadius: AppRadius.rL,
      borderSide: BorderSide(color: color, width: width.r),
    );
