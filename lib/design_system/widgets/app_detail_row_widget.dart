import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

/// صف «لابل ← قيمة».
///
/// منقول من
/// `employee-app/lib/features/money/payslip_details/ui/widgets/payslip_detail_row_widget.dart`
/// — **أحسن API في الأبلكيشن كله**، والـ API محفوظ زي ما هو. التغيير
/// الوحيد: `iconBackgroundColor` افتراضيًا [AppSemanticColors.accentTint]
/// بدل اللون المتحطوط.
///
/// ## ⚠ صف الإجمالي بيستخدم `Wrap` مش `Row`
///
/// اللابل كلمة واحدة ماتتقطعش، والقيمة أكبر خط في الصف — **قص أي واحد
/// فيهم خسارة**. الـ `Wrap` بـ`spaceBetween` بينزّل القيمة سطر تحت بدل ما
/// تفيض، وعند المقاس العادي شكله زي الـ`Row` بالظبط.
class AppDetailRowWidget extends StatelessWidget {
  const AppDetailRowWidget({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    super.key,
  });

  /// **نصوص جاهزة — مش مفاتيح ترجمة.**
  final String label;
  final String value;

  final Color? valueColor;

  /// صف الإجمالي: خط أكبر، وزن أتقل، ومسافة أوسع.
  final bool isTotal;

  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isTotal
        ? AppTextStyles.cardTitle
        : AppTextStyles.bodyMdMuted;
    final valueStyle = isTotal
        ? AppTextStyles.titleLg.copyWith(color: valueColor)
        : AppTextStyles.bodyMdStrong.copyWith(color: valueColor);

    final labelPart = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Container(
            width: 28.r,
            height: 28.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppSemanticColors.accentTint,
              borderRadius: AppRadius.rXs,
            ),
            child: Icon(
              icon,
              size: 16.r,
              color: iconColor ?? AppSemanticColors.accentText,
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
        ],
        Flexible(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final valuePart = Text(value, style: valueStyle, maxLines: 1);

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        vertical: (isTotal ? AppSpacing.s12 : AppSpacing.s8).h,
      ),
      child: isTotal
          ? SizedBox(
              // ⚠ `Wrap` جوه `Column` كروس-ألاينمنت `start` لازم يتلف في
              // عرض لانهائي: الـ `Column` بيدّي قيد **مرن**، والـ `Wrap`
              // ساعتها بيتلم على مقاس محتواه فمايفضلش فراغ لـ
              // `spaceBetween` توزّعه.
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.s8.w,
                runSpacing: AppSpacing.s4.h,
                children: [labelPart, valuePart],
              ),
            )
          : Row(
              children: [
                Expanded(child: labelPart),
                SizedBox(width: AppSpacing.s8.w),
                Flexible(child: valuePart),
              ],
            ),
    );
  }
}

/// نقطة لون + لابل — للمفاتيح تحت الشارتات.
///
/// بتستبدل `working_hours_legend_item_widget.dart` (عام) و
/// `attendance_screen.dart:497 _LegendItemWidget` (خاص).
class AppLegendDotWidget extends StatelessWidget {
  const AppLegendDotWidget({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.s4.w),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
