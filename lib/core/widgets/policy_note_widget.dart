import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **سطر سياسة واحد** — لابل قصيّر + نص المزوّد.
///
/// ## ليه widget مش سطرين `Text`
///
/// عشان **قاعدة الطي تتكتب مرة واحدة**. السياسة اللي المزوّد ما كتبهاش
/// لازم ترسم **ولا حاجة** — مش لابل من غير جسم، ومش نص بديل من عندنا.
/// السطر ده اتكرر في ٤ سطوح (ملخص الحجز · تفاصيل الحجز · حالة الإلغاء ·
/// عدم الحضور)، ولو كل واحد فيهم عمل `if (x.isNotEmpty)` بإيده، أول واحد
/// ينسى بيرجّع الصندوق الفاضي.
///
/// بيرجّع [SizedBox.shrink] لما [text] فاضي — فالأب يقدر يحطه في `Column`
/// من غير شرط.
///
/// ⚠ **الطي بيحصل جوه، بس الفواصل بره.** لو الأب حاطط `AppSpacing` بين
/// العناصر، السطر الفاضي بيسيب الفاصل ورا — فالأب اللي فيه أكتر من سياسة
/// لازم يستخدم [PolicyNoteWidget.column] اللي بتلمّ الموجود بس.
class PolicyNoteWidget extends StatelessWidget {
  const PolicyNoteWidget({
    required this.label,
    required this.text,
    this.maxLines,
    super.key,
  });

  /// «الإلغاء» · «الاسترجاع» · «لو ما حضرتش».
  final String label;

  /// نص المزوّد زي ما هو. فاضي = مافيش رسم خالص.
  final String text;

  /// `null` يعني من غير قص. الصناديق المحسوبة الارتفاع **لازم** تمرّر رقم.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return RichText(
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      text: TextSpan(
        children: <InlineSpan>[
          TextSpan(text: '$label: ', style: AppTextStyles.captionStrong),
          TextSpan(text: text, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  /// عمود من السطور الموجودة بس — **بيلمّ الفاضي قبل ما يحط الفواصل**.
  ///
  /// ده اللي بيمنع الفراغ المكسور: لو من الخمس سياسات واحدة موجودة، مافيش
  /// فاصل اتحط أصلاً.
  static Widget column(List<PolicyNoteWidget> notes, {double? gap}) {
    final visible = notes.where((n) => n.text.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < visible.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: (gap ?? AppSpacing.s8).h),
          visible[i],
        ],
      ],
    );
  }
}
