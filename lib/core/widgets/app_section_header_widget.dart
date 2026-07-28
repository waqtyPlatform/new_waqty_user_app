import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/directional_chevron_widget.dart';

/// لابل قسم — **المكان الوحيد المسموح له يستخدم `AppTextStyles.sectionLabel`.**
///
/// ## الهرمية اتقلبت عن قصد
///
/// كان العنوان ١٨/w600 — **نفس وزن عنوان الكارت اللي تحته بالظبط**. النتيجة
/// إن الصفحة بتقرا عمود واحد مالوش أولوية: العنوان والمحتوى بيتنافسوا.
///
/// دلوقتي اللابل ١٢ رمادي بخط شعري قصير قبله. بقى **كروم**: بيقول «القسم
/// اللي جاي اسمه كده» وبيسيب المحتوى ياخد الصوت. دي حركة تحريرية قديمة —
/// اللابل بيخدم المحتوى مش بينافسه.
///
/// **والتتبّع صفر مش موجب** — فلاتر بيطبّقه بعد التشكيل فبيفكّك الحروف
/// العربية المتصلة. التفاصيل في `AppTextStyles.sectionLabel`.
///
/// والـ widget شايل مسافاته بنفسه (٤٠ فوق · ٨ تحت). لما المسافة بتتكتب في
/// مكان الاستدعاء، بتتفكّك بعد كام شاشة — وده اللي حصل فعلاً: الفاصل قبل
/// «الخدمات» كان ٢٤ وقبل «الأخصائيين» ١٦.
class AppSectionHeaderWidget extends StatelessWidget {
  final String title;

  /// «عرض الكل» وأخواتها.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// أول قسم في الشاشة مالوش فاصل فوقه — الـ AppBar عمل الفصل خلاص.
  final bool isFirst;

  const AppSectionHeaderWidget({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && onAction != null;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: isFirst ? 0 : AppSpacing.sectionBreak.h,
        bottom: AppSpacing.headerToContent.h,
      ),
      child: Row(
        children: [
          // الخط الشعري ده بديل الـ letterSpacing اللي مينفعش في العربي.
          // بيدّي نفس الإشارة التحريرية («ده لابل مش عنوان») من غير ما
          // يلمس تشكيل الحروف.
          _LeadingRule(),
          horizontalSpace(AppSpacing.s8),
          Expanded(child: Text(title, style: AppTextStyles.sectionLabel)),

          // **الفعل نزل مع اللابل.** كان ١٤/w600/أخضر — ولو سبناه كده بعد
          // ما اللابل بقى ١٢ رمادي، «عرض الكل» كانت هتبقى أعلى حاجة صوتًا
          // في الصف. يبقى نقلنا المشكلة مش حلّيناها.
          if (hasAction)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppSpacing.s8.r),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.s4.w,
                  vertical: AppSpacing.s4.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(actionLabel!, style: AppTextStyles.sectionLabel),
                    const DirectionalChevronWidget(
                      size: 16,
                      color: AppSemanticColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// خط شعري قصير قبل اللابل — ١٦ عرض، بكسل فيزيائي واحد.
class _LeadingRule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16.w,
      height: 1 / MediaQuery.devicePixelRatioOf(context),
      child: const ColoredBox(color: AppSemanticColors.borderStrong),
    );
  }
}
