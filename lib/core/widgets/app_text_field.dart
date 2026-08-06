import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';

/// حقل الإدخال.
///
/// ## من الـ design DNA
///
/// > `Rounded 12px border-radius, 1px light gray border, white fill, 48px
/// > height, left-aligned icon prefix for search fields, **label positioned
/// > above the field**`
///
/// ### اللابل فوق مش جوّه
///
/// كل حقول الأبلكيشن كانت `hintText` بس. الـ hint بيختفي **أول حرف** العميل
/// يكتبه — يعني في فورم التسجيل (٧ حقول) لما حد يرجع يراجع اللي كتبه بيلاقي
/// ٧ سطور نص من غير ما يعرف أي واحد فيهم الإيميل وأي واحد الاسم. المشكلة دي
/// مابتبانش وقت الكتابة، بتبان وقت المراجعة — وعشان كده عاشت.
///
/// دلوقتي اللابل قاعد فوق وثابت، والـ hint بقى **مثال** («٠١٠xxxxxxxx»)
/// مش تسمية.
///
/// ### الحد رجع
///
/// الحقل كان غاطس من غير حد (`surfaceSunken` + `BorderSide.none`) — نفس لغة
/// شريط البحث والشيب غير المختار بالظبط، يعني بيقرا **كروم مش مكان كتابة**.
/// السطح المرفوع + الحد ١px بيقولوا «اكتب هنا».
///
/// الشكل كله جاي من `inputDecorationTheme` في `app_theme.dart` — الملف ده
/// بيضيف اللابل والارتفاع بس.
class AppTextFormField extends StatelessWidget {
  /// اللابل اللي بيقعد **فوق** الحقل. سيبه `null` للحقول اللي جوه صف ضيق
  /// (البحث) أو اللي فوقها عنوان قسم أصلاً.
  final String? label;

  final String hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final bool autofocus;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;

  const AppTextFormField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.autofillHints,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      textAlign: textAlign,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onTap: onTap,
      // اللمس بره الحقل بيقفل الكيبورد. كان متكتوب في كل حقل بإيده.
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: AppTextStyles.bodyLg,
      cursorColor: AppSemanticColors.accent,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        // الحقل المعطّل بياخد السطح الغاطس — الفرق ده هو اللي بيقول
        // «مش هتقدر تكتب هنا» من غير ما نكتب كلمة.
        fillColor: enabled
            ? AppSemanticColors.surfaceRaised
            : AppSemanticColors.surfaceSunken,
        // ٤٨ من الـ DNA: نص `bodyLg` (١٦ × ١٫٥ = ٢٤) + ١٢ فوق + ١٢ تحت.
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s12.h,
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: AppSpacing.s8.h,
            start: AppSpacing.s4.w,
          ),
          child: Text(label!, style: AppTextStyles.fieldLabel),
        ),
        field,
      ],
    );
  }
}
