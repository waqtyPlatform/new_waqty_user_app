import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// ثيم الأبلكيشن.
///
/// كان ١١ سطر: `useMaterial3` و`centerTitle` وبس. النتيجة إن كل الـ ripples
/// والمؤشرات والـ spinners كانت **بنفسجي ماتيريال الافتراضي مش أخضر الأبلكيشن**،
/// وكل شاشة كانت بتكتب خلفيتها وشكل الـ sheet بتاعها بإيدها من الأول.
///
/// بيتنادى جوه `ScreenUtilInit` (`my_app.dart`) — فاستخدام `.sp`/`.r` هنا آمن.
ThemeData themeData() {
  final colorScheme = ColorScheme.light(
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
    fontFamily: 'IBMPlexSansArabic',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppSemanticColors.page,
    visualDensity: VisualDensity.standard,

    // InkRipple أنعم من InkSparkle بتاعة M3 — أقرب للإحساس اللي احنا رايحينله.
    splashFactory: InkRipple.splashFactory,
    splashColor: AppSemanticColors.accent.withValues(alpha: .08),
    highlightColor: AppSemanticColors.accent.withValues(alpha: .04),

    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLg,
      headlineSmall: AppTextStyles.titleXl,
      titleLarge: AppTextStyles.titleLg,
      titleMedium: AppTextStyles.sectionHeader,
      titleSmall: AppTextStyles.cardTitle,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.bodyMd,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.label,
      labelSmall: AppTextStyles.overline,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppSemanticColors.page,
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
      systemOverlayStyle: SystemUiOverlayStyle.dark,
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

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppSemanticColors.surfaceSunken,
      hintStyle: AppTextStyles.bodyMd.copyWith(
        color: AppSemanticColors.textOnSunken,
      ),
      contentPadding: EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.s16.w,
        vertical: 14.h,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.rM,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.rM,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.rM,
        borderSide: BorderSide(color: AppSemanticColors.accent, width: 1.5.r),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.rM,
        borderSide: BorderSide(color: AppSemanticColors.danger, width: 1.5.r),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.rM,
        borderSide: BorderSide(color: AppSemanticColors.danger, width: 1.5.r),
      ),
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
        // كل زرار نصي بياخد الحد الأدنى للمس من هنا — وده بيشيل الـ ٥ مواضع
        // اللي كانت بتلفّه في SizedBox(height: 44) بالإيد.
        minimumSize: Size(0, AppSpacing.touchTarget.r),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppSemanticColors.accent,
        textStyle: AppTextStyles.label,
        side: BorderSide(color: AppSemanticColors.accent),
        shape: const StadiumBorder(),
        minimumSize: Size(0, AppSpacing.touchTarget.r),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppSemanticColors.accent,
        foregroundColor: AppSemanticColors.textOnAccent,
        textStyle: AppTextStyles.button,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rM),
        minimumSize: Size(double.infinity, 52.h),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
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
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppSemanticColors.surfaceInverse,
      contentTextStyle: AppTextStyles.bodyMd.copyWith(
        color: AppSemanticColors.textOnAccent,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rS),
      insetPadding: EdgeInsets.all(AppSpacing.s16.w),
      elevation: 0,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppSemanticColors.surfaceRaised,
      selectedItemColor: AppSemanticColors.accent,
      unselectedItemColor: AppSemanticColors.textSecondary,
      selectedLabelStyle: AppTextStyles.captionStrong,
      unselectedLabelStyle: AppTextStyles.caption,
      type: BottomNavigationBarType.fixed,
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
