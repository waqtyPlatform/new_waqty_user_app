import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/directional_chevron_widget.dart';

/// صف في قايمة الحساب.
///
/// **مالوش سطح بتاعه.** الصفوف بتتجمّع جوه `AccountMenuGroupWidget`،
/// وده اللي بيدّي الظل والاستدارة. لما كل صف كان سطح لوحده، الخمس صفوف
/// كانوا بيضا على أبيض من غير أي فصل — أوحش مشكلة كثافة في الأبلكيشن.
///
/// ## الحشوة الأفقية جوه الصف مش على المجموعة
///
/// نفس قاعدة `AppRowWidget`: الهامش بيقعد **جوه** الصف. لما كان على الـ
/// `Column` بتاع المجموعة كان بيعمل حاجتين غلط — الـ ripple بتوقف ١٢
/// بكسل قبل حافة الكارت (فبتقرا مربع مش صف)، والخط الشعري كمان بيوقف
/// قبل الحافة فبيبقى شخطة طايرة مش فاصل قايمة.
///
/// ## مفيش `color` تتبعت من بره
///
/// كان في باراميتر لون «للأفعال الخطرة» ومحطوط عشان الخروج — والخروج
/// طلع من القايمة خالص وبقى نص أحمر تحت المجموعتين، فالباراميتر فضل
/// متبعتش ولا مرة والتوثيق بتاعه بقى بيشاور على مستهلك مش موجود.
///
/// وده مقصود مش صدفة: **الصف ده مايعرفش يصرّخ.** لو حاجة خطرة دخلت
/// القايمة بكرة، الأحمر جوه صف رمادي بين خمس صفوف بيقرا زينة مش تحذير
/// — مكانه بره الكارت زي الخروج بالظبط.
class AccountMenuItemWidget extends StatelessWidget {
  /// مقاس أيقونة الصف. مصدّرة عشان `AccountMenuGroupWidget` يحسب منها
  /// إزاحة الخط الشعري بدل ما يكتب ٣٢ بإيده.
  static const double iconSize = 20;

  /// إزاحة الخط الشعري: ١٢ حشوة + ٢٠ أيقونة + ١٢ مسافة = **٤٤** —
  /// يعني الفاصل بيبدأ من تحت اللابل بالظبط، مش من حافة الكارت.
  static const double hairlineIndent =
      AppSpacing.cardPadding + iconSize + AppSpacing.s12;

  /// **الحسبة:** ٥٦ الأصلية = ٣٥ حشوة رأسية + ٢١ نص
  /// (`bodyMdStrong` ١٤ × ١٫٥٠).
  static const double _fixedPart = 35;
  static const double _textPart = 21;

  /// كان `56.h` أصم. عند مقياس خط ١٫٣ النص بيوصل ٢٧٫٣ فالسطر بيتخنق في
  /// صندوقه — الحشوة فوق وتحت بتنزل من ١٧٫٥ لـ ١٤٫٤ والصف بيقرا مضغوط.
  static double heightOf(BuildContext context) =>
      AppSpacing.scaledHeight(context, fixed: _fixedPart, text: _textPart);

  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;

  const AccountMenuItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: heightOf(context).h,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.cardPadding.w,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: iconSize.r,
                color: AppSemanticColors.textPrimary,
              ),
              horizontalSpace(AppSpacing.s12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMdStrong,
                ),
              ),
              if (trailingText != null) ...[
                Text(trailingText!, style: AppTextStyles.bodyMdMuted),
                horizontalSpace(AppSpacing.s4),
              ],
              const DirectionalChevronWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
