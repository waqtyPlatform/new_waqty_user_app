import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_format.dart';
import 'package:waqty_user_application/core/utils/app_radius.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/app_button_widget.dart';

/// «الميعاد ده مش مناسب» — والسبب.
///
/// ## ليه السبب مطلوب مش اختياري
///
/// `UserWaitlistController::requestChange` بيعمل `'note' => ['required']`.
/// وده مش تشدّد إداري: عدد العروض **معدود** (`MAX_OFFERS`)، فالفرع اللي
/// مايعرفش إيه المشكلة هيبعت نفس نوع الميعاد تاني ويحرق محاولة.
///
/// الاقتراحات السريعة موجودة عشان أغلب الأسباب أربعة أو خمسة، وكتابة
/// جملة على موبايل وإنت مستعجل تكلفة حقيقية بتخلي الناس تسيب الطلب.
class WaitlistChangeRequestSheet extends StatefulWidget {
  final WaitlistUiModel entry;

  const WaitlistChangeRequestSheet({super.key, required this.entry});

  /// بترجّع السبب اللي العميل كتبه، أو `null` لو قفل الـ sheet.
  static Future<String?> show(BuildContext context, WaitlistUiModel entry) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WaitlistChangeRequestSheet(entry: entry),
    );
  }

  @override
  State<WaitlistChangeRequestSheet> createState() =>
      _WaitlistChangeRequestSheetState();
}

class _WaitlistChangeRequestSheetState
    extends State<WaitlistChangeRequestSheet> {
  // ⚠ `TextEditingController` **لازم** يعيش في `State` — مش في Cubit.
  // ده مورد بيتعمله dispose، والقاعدة «مفيش setState» بتخص حالة الشاشة
  // مش دورة حياة الـ controllers. نفس اللي `booking_details_screen` عامله.
  final TextEditingController _controller = TextEditingController();

  /// الأسباب اللي بتغطي أغلب الحالات — دوسة واحدة بدل جملة.
  static const List<String> _quickReasons = <String>[
    'الميعاد بدري عليّا',
    'الميعاد متأخر عليّا',
    'مش هينفع في اليوم ده',
    'عايز أخصائي تاني',
  ];

  String? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasReason =>
      _selected != null || _controller.text.trim().isNotEmpty;

  String get _reason =>
      _controller.text.trim().isNotEmpty ? _controller.text.trim() : _selected!;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Padding(
      // الكيبورد بيغطي الحقل من غير ده.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppSemanticColors.surfaceRaised,
          borderRadius: AppRadius.sheetTop,
        ),
        padding: EdgeInsetsDirectional.all(AppSpacing.s16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الميعاد ده مش مناسب؟', style: AppTextStyles.titleLg),
            verticalSpace(AppSpacing.titleToSubtitle),
            // بنفكّره بالميعاد اللي بيرفضه — الـ sheet بتغطي الكارت.
            if (entry.offeredStartAt != null)
              Text(
                'المعروض: ${AppFormat.relativeDate(entry.offeredStartAt!)}'
                ' · ${AppFormat.time(entry.offeredStartAt!)}',
                style: AppTextStyles.caption,
              ),
            verticalSpace(AppSpacing.s12),
            Text(
              'قول للفرع إيه المشكلة عشان العرض اللي بعده يبقى أقرب.',
              style: AppTextStyles.caption,
            ),
            verticalSpace(AppSpacing.s12),

            Wrap(
              spacing: AppSpacing.s8.w,
              runSpacing: AppSpacing.s8.h,
              children: <Widget>[
                for (final reason in _quickReasons)
                  _ReasonChip(
                    label: reason,
                    isSelected: _selected == reason,
                    onTap: () => setState(() {
                      _selected = _selected == reason ? null : reason;
                      _controller.clear();
                    }),
                  ),
              ],
            ),

            verticalSpace(AppSpacing.s12),
            TextField(
              controller: _controller,
              maxLines: 2,
              maxLength: 300,
              onChanged: (_) => setState(() => _selected = null),
              decoration: InputDecoration(
                hintText: 'أو اكتب السبب بنفسك',
                hintStyle: AppTextStyles.caption,
                counterText: '',
                border: OutlineInputBorder(borderRadius: AppRadius.rS),
              ),
            ),

            verticalSpace(AppSpacing.s16),
            AppButtonWidget(
              label: 'ابعت للفرع',
              // مقفول لحد ما يبقى فيه سبب — السيرفر هيرفض الطلب الفاضي
              // بـ٤٢٢، وزرار بيدوس ويرجّع خطأ أوحش من زرار مقفول.
              onPressed: _hasReason
                  ? () => Navigator.of(context).pop(_reason)
                  : null,
            ),
            verticalSpace(AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rPill,
      child: Container(
        // **`.r` مش `.h`** — هدف اللمس لازم يفضل ٤٤ في كل الاتجاهات.
        constraints: BoxConstraints(minHeight: AppSpacing.touchTarget.r),
        alignment: Alignment.center,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.s12.w,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppSemanticColors.accentSoft
              : AppSemanticColors.surfaceSunken,
          borderRadius: AppRadius.rPill,
          border: isSelected
              ? Border.all(color: AppSemanticColors.accent)
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? AppSemanticColors.accent
                : AppSemanticColors.textOnSunken,
          ),
        ),
      ),
    );
  }
}
