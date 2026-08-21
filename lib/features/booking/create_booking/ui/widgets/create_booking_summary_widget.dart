import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/policy_note_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/booking_draft_item.dart';
import 'package:waqty_user_application/features/booking/create_booking/logic/create_booking_cubit.dart';

/// شاشة التأكيد — **مجمّعة بالزيارة**.
///
/// الزيارة = رحلة للمحل. عادةً يوم واحد، بس مش دايمًا: صبغة الصبح وحمام
/// كريم بالليل في نفس اليوم دول رحلتين، والعميل بيروح ويرجع.
///
/// وهي أول وآخر مرة العميل يشوف الكلمة: وهو بيحجز كان بيضيف خدمات
/// ويحدّد مواعيد وخلاص، وهنا بس بيشوف الشكل النهائي اللي هيروح بيه.
///
/// ## ليه فيه زرار على الفواصل
///
/// السيرفر بياخد تجميع الزيارات زي ما بيتبعت وماعندوش قاعدة يراجعه بيها،
/// و`checkInVisit` بيسجّل وصول **واحد للزيارة كلها**. يعني دمج غلط
/// بيخلي الفرع يعمل check-in الصبح والعميل يفضل «واصل» لحد بالليل.
///
/// الفارق بيقرر لوحده في الحالة الشائعة، بس القرار ظاهر وقابل للتعديل —
/// لأن العميل هو الوحيد اللي عارف هو هيقعد مستني ولا هيروح ويرجع.
class CreateBookingSummaryWidget extends StatelessWidget {
  final CreateBookingCubit cubit;

  const CreateBookingSummaryWidget({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **سطر واحد بدل صفّين لابل/قيمة.**
        //
        // كان «المكان: صالون كابتن» و«الفرع: فرع المعادي» — صفّين نصهم
        // أسماء حقول، **والفرع مكتوب فوقيهم بالظبط** في شارة الهيدر بتاعة
        // الـ sheet. يعني تكرار على تكرار في شاشة المفروض تكون أنضف شاشة
        // في الفلو (دي اللي العميل بيوافق منها).
        _place(),
        verticalSpace(AppSpacing.s16),

        ..._timeline(),

        verticalSpace(AppSpacing.s8),
        _NotesField(cubit: cubit),

        verticalSpace(AppSpacing.s16),
        const AppHairlineWidget(),
        verticalSpace(AppSpacing.s12),

        // **`Wrap` مش `Row`.**
        //
        // اللابل «الإجمالي» كلمة واحدة ماتتقطعش، والسعر أكبر خط في الشاشة.
        // في `Row` لازم واحد فيهم يتضحّي لما الاتنين مايكفوش — والاتنين
        // مش قابلين للتضحية: تقصير الإجمالي بنقط يخلّيه مش مقروء، وتصغير
        // الرقم يضرب الغرض من إن المستخدم كبّر الخط أصلاً.
        //
        // الـ `Wrap` بينزّل السعر لسطر تحت اللابل بدل ما يفيض. عند المقاس
        // العادي الاتنين على سطر واحد بـ`spaceBetween` — نفس الشكل بالظبط.
        //
        // ⚠ الـ `SizedBox` مش زيادة: الـ `Column` فوق `crossAxisAlignment`
        // بتاعه `start`، يعني بيدّي ولاده قيد **مرن**، والـ `Wrap` ساعتها
        // بيتلم على مقاس محتواه ومايفضلش فراغ لـ`spaceBetween` توزّعه —
        // فاللابل والسعر بيلزقوا في بعض بدل ما يبقوا على الطرفين.
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.s8.w,
            runSpacing: AppSpacing.s4.h,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('الإجمالي', style: AppTextStyles.bodyMdMuted),
                  // عدد الخدمات جنب اللابل — عشان الرقم الكبير يبقى مفهوم
                  // إنه مجموع، مش سعر خدمة.
                  if (cubit.items.length > 1) ...[
                    horizontalSpace(AppSpacing.s8),
                    Flexible(
                      child: Text(
                        '${AppFormat.digits(cubit.items.length)} خدمات · '
                        '${AppFormat.duration(cubit.totalDuration)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ],
              ),
              // أكبر خط في الشاشة — ده الرقم اللي العميل بيوافق عليه.
              //
              // **[AppAmountWidget] مش `Text` بستايل.** بيفصل الرقم عن
              // العملة: الرقم ٢٤ و«ج.م» أصغر وأخف. الفرق إن العين بتقع
              // على الرقم مش على الوحدة — والوحدة واحدة في الأبلكيشن كله
              // فمالهاش لازمة تاخد نفس الوزن.
              AppAmountWidget(
                amount: AppFormat.money(cubit.totalPrice, withCurrency: false),
                currency: AppFormat.currency,
              ),
            ],
          ),
        ),
        verticalSpace(AppSpacing.s4),
        Text('الدفع في الفرع', style: AppTextStyles.caption),

        // **شرط الإلغاء بتاع المزوّد — تحت الإجمالي مباشرة.**
        //
        // ده شرط في الاتفاق اللي العميلة على وشك توافق عليه، فمكانه جنب
        // الرقم اللي بتوافق عليه مش في شاشة تانية. والسطر بيختفي بالكامل
        // لو المزوّد ما كتبش سياسة — **مابنكتبش واحدة من عندنا**، ودي
        // بالظبط الغلطة اللي كانت في شيت ما بعد الإلغاء.
        // TODO(api): BE-B1.
        if ((cubit.selectedBranch?.policies.cancellationPolicy ?? '')
            .isNotEmpty) ...[
          verticalSpace(AppSpacing.s8),
          PolicyNoteWidget(
            label: 'الإلغاء',
            text: cubit.selectedBranch!.policies.cancellationPolicy,
          ),
        ],

        // أهم سطر في الشاشة كلها.
        //
        // العميل اللي يكتشف إنه ارتبط بحاجة مش قادر يلغيها **بعد** ما
        // يأكد — دي أوحش خسارة ثقة ممكنة في المنتج ده، وثمنها سطر واحد
        // في المكان الصح.
        //
        // ⚠ **القاعدة إن الميعاد يبدأ، مش إنه النهاردة.**
        // `Booking::getCanCancelAttribute()` بيقفل الإلغاء لما الميعاد
        // **يعدّي**. النص القديم كان بيقول إن حجز النهاردة مايتلغيش من
        // أصله — وده منع مش موجود، والعميل كان بيوافق وهو فاكر إنه بيتنازل
        // عن حق هو أصلاً معاه لحد ما الميعاد يبدأ.
        //
        // الشرط `isSameDayBooking` بيفضل صح كـ**فلتر أهمية**: التنبيه
        // بيلزم لما الميعاد قريب كفاية إن النافذة تقفل النهاردة.
        if (cubit.isSameDayBooking) ...[
          verticalSpace(AppSpacing.s16),
          _Notice(
            message: cubit.items.length > 1
                ? 'فيه خدمة النهاردة — بعد ما تبدأ مش هينفع تلغيها من الأبلكيشن'
                : 'ميعادك النهاردة — بعد ما يبدأ مش هينفع تلغيه من الأبلكيشن',
          ),
        ],
        verticalSpace(AppSpacing.s16),
      ],
    );
  }

  /// الزيارات وفواصلها بالترتيب الزمني.
  ///
  /// الفاصل بيتحط **قبل** عنوان الزيارة اللي بعده — عشان يقرا «فيه فراغ
  /// هنا، فبتبدأ زيارة جديدة» بدل ما يقرا كأنه تابع للزيارة اللي فاتت.
  List<Widget> _timeline() {
    final visits = cubit.visits;
    final widgets = <Widget>[];

    for (var v = 0; v < visits.length; v++) {
      final visit = visits[v];

      final openingBoundary = cubit.boundaryBefore(visit.first);
      if (openingBoundary != null) {
        widgets.add(
          _BoundaryRow(
            boundary: openingBoundary,
            onToggle: cubit.toggleBoundary,
          ),
        );
      }

      widgets.add(
        _VisitHeader(
          title: _visitTitle(v, visits.length),
          date: visit.first.selectedSlot!.startAt,
        ),
      );

      for (var i = 0; i < visit.length; i++) {
        if (i > 0) {
          final boundary = cubit.boundaryBefore(visit[i]);
          if (boundary != null) {
            widgets.add(
              _BoundaryRow(boundary: boundary, onToggle: cubit.toggleBoundary),
            );
          }
        }
        widgets.add(
          _ItemLine(
            item: visit[i],
            onChange: cubit.goToItem,
            showPrice: cubit.items.length > 1,
          ),
        );
      }

      widgets.add(verticalSpace(AppSpacing.s16));
    }

    return widgets;
  }

  /// زيارة واحدة؟ اليوم لوحده يكفي — كلمة «الزيارة» ساعتها ضوضاء.
  String _visitTitle(int index, int total) {
    if (total == 1) return '';
    const ordinals = <String>[
      'الزيارة الأولى',
      'الزيارة التانية',
      'الزيارة التالتة',
      'الزيارة الرابعة',
      'الزيارة الخامسة',
    ];
    if (index < ordinals.length) return ordinals[index];
    return 'الزيارة ${AppFormat.digits(index + 1)}';
  }

  /// اسم المحل — **من غير لابل ومن غير الفرع**.
  ///
  /// الفرع عايش في شارة الهيدر فوق (وقابل للتغيير من هناك)، فتكراره هنا
  /// بيسأل العميل يقرا نفس الكلمة مرتين في ٤٠ بكسل.
  Widget _place() {
    return Row(
      children: [
        Icon(
          Icons.storefront_rounded,
          size: 18.r,
          color: AppSemanticColors.textTertiary,
        ),
        horizontalSpace(AppSpacing.s8),
        Expanded(
          child: Text(
            cubit.providerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMdStrong,
          ),
        ),
      ],
    );
  }
}

/// رأس الزيارة — **التاريخ شارة**.
///
/// كان نص عريض سايب. الشارة بتديه حدود، فبيقرا كـ«ده اليوم» بدل ما يقرا
/// كعنوان تاني بعد اسم المحل — ونفس لغة التاريخ في تفاصيل الحجز وصف
/// الحجوزات.
class _VisitHeader extends StatelessWidget {
  final String title;
  final DateTime date;

  const _VisitHeader({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.headerToContent.h),
      child: Row(
        children: [
          if (title.isNotEmpty) ...[
            // `Flexible` مش نص سايب: «الزيارة التالتة» + شارة تاريخ كامل
            // مابيدخلوش في سطر واحد عند مقياس خط ١٫٣.
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.overline,
              ),
            ),
            horizontalSpace(AppSpacing.s8),
          ],
          Flexible(
            child: AppPillWidget(
              label: AppFormat.fullDate(date),
              icon: Icons.calendar_today_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

/// الفاصل بين خدمتين في نفس اليوم — بيعرض الفراغ وبيدّي قرار.
///
/// السؤال هو نص الزرار نفسه: الضغط بيطبّقه. أقصر من لابل + زرار، وأوضح
/// من أيقونة محدش هيفهمها.
class _BoundaryRow extends StatelessWidget {
  final VisitBoundary boundary;
  final ValueChanged<String> onToggle;

  const _BoundaryRow({required this.boundary, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.s4.h),
      child: Row(
        children: [
          Icon(
            boundary.isBreak
                ? Icons.directions_walk_rounded
                : Icons.more_time_rounded,
            size: 16.r,
            color: AppSemanticColors.textTertiary,
          ),
          horizontalSpace(AppSpacing.s8),
          Expanded(
            child: Text(
              'بينهم ${AppFormat.duration(boundary.gap.inMinutes)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ),
          SizedBox(
            height: AppSpacing.touchTarget.h,
            child: TextButton(
              onPressed: () => onToggle(boundary.itemKey),
              child: Text(
                boundary.isBreak ? 'نفس الرحلة؟' : 'رحلتين منفصلتين؟',
                style: AppTextStyles.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemLine extends StatelessWidget {
  final BookingDraftItem item;
  final ValueChanged<String> onChange;

  /// **بيتخفي لما الحجز خدمة واحدة.**
  ///
  /// ساعتها سعر الخدمة = الإجمالي بالظبط، فالرقم كان بيتعرض **تلات مرات**
  /// في نفس الشاشة (السطر ده · الإجمالي · الفوتر). التكرار في شاشة موافقة
  /// بيخلي العميل يعدّ الأرقام بدل ما يقراها.
  final bool showPrice;

  const _ItemLine({
    required this.item,
    required this.onChange,
    required this.showPrice,
  });

  @override
  Widget build(BuildContext context) {
    final slot = item.selectedSlot!;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s4.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd,
                ),
                verticalSpace(AppSpacing.titleToSubtitle),
                Text(
                  '${AppFormat.timeRange(slot.startAt, slot.endAt)}'
                  ' · مع ${item.resolvedEmployeeName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (showPrice) ...[
            horizontalSpace(AppSpacing.s8),
            Text(
              AppFormat.money(item.price),
              maxLines: 1,
              style: AppTextStyles.bodyMdStrong,
            ),
          ],
          SizedBox(
            height: AppSpacing.touchTarget.h,
            child: TextButton(
              onPressed: () => onChange(item.key),
              child: Text('تغيير', style: AppTextStyles.label),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String message;

  const _Notice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.s12.r),
      decoration: BoxDecoration(
        color: AppSemanticColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.s.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.r,
            color: AppSemanticColors.warning,
          ),
          horizontalSpace(AppSpacing.s8),
          Expanded(child: Text(message, style: AppTextStyles.captionInk)),
        ],
      ),
    );
  }
}

/// الملاحظات — مطوية لحد ما العميل يطلبها.
///
/// الحقل كان موجود في الـ cubit من الأول (`notesController`) ومكانش
/// معروض في أي شاشة، مع إن الـ API بيقبل `notes`. مفتوح طول الوقت
/// بياخد مساحة من غالبية مالهاش ملاحظات، فبيتفتح بالضغط.
class _NotesField extends StatelessWidget {
  final CreateBookingCubit cubit;

  const _NotesField({required this.cubit});

  @override
  Widget build(BuildContext context) {
    if (!cubit.isNotesExpanded) {
      // `TextButton` بـ`Row` مكتوب بالإيد مش `TextButton.icon`: الأخيرة
      // بتحط الأيقونة واللابل في `Row` جواها من غير `Flexible`، فعند
      // مقياس خط ١٫٣ اللابل الطويل بيفيّض الزرار.
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton(
          onPressed: cubit.toggleNotes,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 20.r),
              horizontalSpace(AppSpacing.s4),
              Flexible(
                child: Text(
                  'ضيف ملاحظة للمحل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.s8.h),
      child: TextField(
        controller: cubit.notesController,
        maxLines: 3,
        minLines: 2,
        maxLength: 1000,
        style: AppTextStyles.bodyMd,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          filled: true,
          fillColor: AppSemanticColors.surfaceSunken,
          hintText: 'أي حاجة تحب المحل يعرفها؟',
          hintStyle: AppTextStyles.bodyMdMuted,
          contentPadding: EdgeInsets.all(AppSpacing.s12.r),
          // ١٢ — نفس استدارة كل حقول الأبلكيشن (من الـ design DNA).
          // الملء غاطس مش مرفوع عن قصد: الحقل ده جوه sheet مرفوع أصلاً،
          // والمرفوع على المرفوع مش بيبان.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.s.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
