import 'package:flutter/material.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/provider_row_widget.dart';

/// التحميل بشكل [ProviderRowWidget] بالظبط.
///
/// ## بيستخدم [AppRowWidget] نفسه — مش بينسخ حشوته
///
/// كان بيرسم `SizedBox → Padding → Row` بإيده و«بيقلّد» حشوة الصف. التقليد
/// ده اتكسر مرتين: أول ما الصف بقى كارت (الـ skeleton فضل صف مسطّح)، وأول
/// ما حشوة الكارت اتغيّرت من ١٢ لـ ١٦.
///
/// دلوقتي الاتنين بيمرّوا على نفس الـ widget بنفس `heightOf` — يعني عدم
/// التطابق بقى **مستحيل بنيويًا**، مش «متظبط دلوقتي».
///
/// موجة الـ shimmer واحدة للصف كله ([AppSkeletonGroupWidget] بره) بدل موجة لكل
/// مستطيل — من غيرها بيبقى وميض عشوائي مش حركة ماشية.
class ProviderRowSkeletonWidget extends StatelessWidget {
  final bool showHairline;

  const ProviderRowSkeletonWidget({super.key, this.showHairline = true});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonGroupWidget(
      child: AppRowWidget(
        height: ProviderRowWidget.heightOf(context),
        showHairline: showHairline,
        leading: AppSkeletonBoxWidget(
          width: ProviderRowWidget.avatarSize,
          height: ProviderRowWidget.avatarSize,
          radius: AppRadius.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الأعراض بتقلّ وبتزيد زي النص الحقيقي — الاسم أطول من
            // التصنيف، والبيانات أطول من الاتنين. أربع مستطيلات متساوية
            // بتقرا جدول مش نص.
            const AppSkeletonBoxWidget(width: 140, height: 14),
            verticalSpace(AppSpacing.s8),
            const AppSkeletonBoxWidget(width: 100, height: 10),
            verticalSpace(AppSpacing.s8),
            const AppSkeletonBoxWidget(width: 168, height: 10),
            verticalSpace(AppSpacing.s8),
            // السطر الرابع بقى **شارة** في الصف الحقيقي، فالعرض بتاعه هنا
            // شارة كمان — مستطيل رفيع مكانها بيخلي الشكل يتبدّل لما الداتا
            // توصل.
            const AppSkeletonBoxWidget(
              width: 150,
              height: 22,
              radius: AppRadius.pill,
            ),
          ],
        ),
      ),
    );
  }
}
