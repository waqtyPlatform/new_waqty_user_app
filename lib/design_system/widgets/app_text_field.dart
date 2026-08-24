import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_icons.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';
import 'app_icon_widget.dart';

/// حقل نص.
///
/// ## ⚠ هنا بالظبط باج DMSans بيموت
///
/// `employee-app/lib/core/utils/styles.dart:339` بيعلن
/// `font16BlackColorWeight400` بـ `fontFamily: 'DMSans'` — خط **مش في
/// الـ pubspec ولا على الديسك** — وده الستايل المستخدم في
/// `app_text_field.dart:132` (الـ hint) و`:141` (النص). يعني **كل حقل
/// إدخال في الأبلكيشن النهاردة بيرسم بخط النظام الاحتياطي**، وشكل
/// العربي فيه مختلف عن باقي الشاشة.
///
/// ## اللي اتشال
///
/// أربع باراميترات ميتة كانت معلنة ومحدش بيقراها: `inputTextStyle` ·
/// `isPhoneNumber` · `isRegister` · `isLogin`. والخمس `OutlineInputBorder`
/// المكتوبين بالإيد راحوا لـ `inputDecorationTheme` في `appTheme()` —
/// فالحقل والـ dropdown والبحث بقوا **مضمون** إنهم نفس الشكل.
class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    required this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.textAlign,
    this.focusNode,
    this.autofillHints,
    super.key,
  });

  /// **نص جاهز — مش مفتاح ترجمة.**
  final String hintText;

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign? textAlign;
  final FocusNode? focusNode;

  /// ⚠ **مش تجميل.** من غيرها مدير كلمات السر وملء كود الـOTP التلقائي
  /// بيموتوا في كل فورمة دخول، والعميل بيحسّها «التطبيق نسي باسوردي».
  /// وده الشكل الوحيد اللي ممكن يتحط بيه — `AutofillHints` لازم تقعد على
  /// الحقل نفسه، فغلاف من بره **مايقدرش** يضيفها.
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofillHints: autofillHints,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: textAlign ?? TextAlign.start,
      // الخط بييجي من `bodyLg` مش من ستايل بخط مش موجود.
      style: AppTextStyles.bodyLg.copyWith(
        color: enabled
            ? AppSemanticColors.textPrimary
            : AppSemanticColors.textTertiary,
      ),
      cursorColor: AppSemanticColors.accent,
      // كل الشكل من `inputDecorationTheme` — مافيش حدود متكتوبة هنا.
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength == null ? null : '',
        fillColor: enabled
            ? AppSemanticColors.surfaceRaised
            : AppSemanticColors.surfaceSunken,
      ),
    );
  }
}

/// حقل بلابل فوقه ورسالة تحته.
///
/// employee-app **مافيهوش لابل حقل أصلًا** — الـ hint كان بيقوم بالدورين،
/// فأول ما العميل يكتب بيختفي السؤال. الغلاف ده بيفصل الاتنين.
class AppFieldWidget extends StatelessWidget {
  const AppFieldWidget({
    required this.label,
    required this.child,
    this.helper,
    this.error,
    this.isOptional = false,
    this.optionalLabel,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String label;
  final String? helper;
  final String? error;

  final Widget child;
  final bool isOptional;

  /// اللابل اللي بيتكتب جنب «اختياري». الكيت مالوش لوكلة فالنص بييجي
  /// من بره؛ الافتراضي `'اختياري'` لأن السوق المستهدف عربي.
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.fieldLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isOptional) ...[
              SizedBox(width: AppSpacing.s4.w),
              Text(
                optionalLabel ?? 'اختياري',
                style: AppTextStyles.overline.copyWith(
                  color: AppSemanticColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: AppSpacing.s4.h),
        child,
        if (error != null) ...[
          SizedBox(height: AppSpacing.s4.h),
          Text(
            error!,
            style: AppTextStyles.caption.copyWith(
              color: AppSemanticColors.danger,
            ),
          ),
        ] else if (helper != null) ...[
          SizedBox(height: AppSpacing.s4.h),
          Text(helper!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

/// حقل كلمة سر بزرار إظهار.
///
/// ⚠ **زرار الإظهار هدف لمس كامل.** لو اتحط كـ`Icon` عاري بيبقى ٢٠ نقطة،
/// وهو من أكتر الأزرار اللي بتتداس في أي تطبيق.
class AppPasswordFieldWidget extends StatefulWidget {
  const AppPasswordFieldWidget({
    required this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.autofillHints,
    super.key,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;

  /// ⚠ **حقل السر هو أكتر مكان محتاجها.** من غيرها مدير كلمات السر
  /// مابيملاش، والعميل بيحسّها «التطبيق نسي باسوردي».
  /// `AutofillHints.password` للدخول و`newPassword` لإنشاء/تغيير السر.
  final Iterable<String>? autofillHints;

  @override
  State<AppPasswordFieldWidget> createState() => _AppPasswordFieldWidgetState();
}

class _AppPasswordFieldWidgetState extends State<AppPasswordFieldWidget> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      hintText: widget.hintText,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      obscureText: _hidden,
      keyboardType: TextInputType.visiblePassword,
      suffixIcon: Semantics(
        button: true,
        label: _hidden ? 'إظهار كلمة السر' : 'إخفاء كلمة السر',
        child: GestureDetector(
          onTap: () => setState(() => _hidden = !_hidden),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: AppSpacing.touchTarget.r,
            height: AppSpacing.touchTarget.r,
            child: AppIconWidget(
              _hidden ? AppIcons.visibilityOff : AppIcons.visibility,
              size: 20,
              color: AppSemanticColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
