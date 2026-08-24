import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

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
    // الخلفية والاستدارة ومقبض السحب كلهم من `bottomSheetTheme` —
    // النسخة القديمة كانت بتخلي الحاجب شفاف وبترسم `Container` باستدارة
    // `sheetTop` بإيدها، يعني نسخة تانية من نفس القرار.
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
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

    return AppSheetWidget(
      title: 'الميعاد ده مش مناسب؟',
      // بنفكّره بالميعاد اللي بيرفضه — الـ sheet بتغطي الكارت.
      message: entry.offeredStartAt == null
          ? 'قول للفرع إيه المشكلة عشان العرض اللي بعده يبقى أقرب.'
          : 'المعروض: ${AppFormat.relativeDate(entry.offeredStartAt!)}'
                ' · ${AppFormat.time(entry.offeredStartAt!)}\n'
                'قول للفرع إيه المشكلة عشان العرض اللي بعده يبقى أقرب.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: AppSpacing.s8.w,
            runSpacing: AppSpacing.s8.h,
            children: <Widget>[
              for (final reason in _quickReasons)
                AppChipWidget(
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
            decoration: const InputDecoration(
              hintText: 'أو اكتب السبب بنفسك',
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        AppButtonWidget(
          label: 'ابعت للفرع',
          // مقفول لحد ما يبقى فيه سبب — السيرفر هيرفض الطلب الفاضي
          // بـ٤٢٢، وزرار بيدوس ويرجّع خطأ أوحش من زرار مقفول.
          onPressed: _hasReason
              ? () => Navigator.of(context).pop(_reason)
              : null,
        ),
      ],
    );
  }
}
