import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/package_offer_ui_model.dart';
import 'package:waqty_user_application/core/widgets/discount_price_widget.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **تفاصيل باقة معروضة** — قبل ما العميلة تروح الفرع تسأل.
///
/// ## ليه ورقة مش شاشة
///
/// القرار هنا واحد: «الباقة دي تستاهل؟». اللي بيجاوبه أربع حاجات — إيه
/// جواها، بتسري قد إيه، السعر، ووفّرتِ كام. ده حجم ورقة. شاشة كانت
/// هتاخد راوت وزرار رجوع عشان تعرض نص شاشة فاضي.
///
/// ⚠ **مافيش زرار شرا هنا كمان.** الفعل الحقيقي بيحصل في الفرع، والورقة
/// بتقفل بـ«تمام». لو اتضاف endpoint شرا بعدين، ده مكانه.
class PackageOfferSheet {
  const PackageOfferSheet._();

  static Future<void> show(
    BuildContext context, {
    required PackageOfferUiModel package,
  }) => AppSheetWidget.show<void>(
    context,
    title: package.name,
    message: package.description.isEmpty ? null : package.description,
    icon: Icons.inventory_2_outlined,
    content: _Body(package: package),
    actions: (sheetContext) => <Widget>[
      AppButtonWidget(
        label: 'تمام',
        onPressed: () => Navigator.of(sheetContext).pop(),
      ),
    ],
  );
}

/// ⚠ **مش `const`** — بيرسم لون.
class _Body extends StatelessWidget {
  const _Body({required this.package});

  final PackageOfferUiModel package;

  String get _content => switch (package.type) {
    PackageOfferType.multiSession =>
      '${AppFormat.digits(package.sessionsIncluded ?? 0)} جلسات',
    PackageOfferType.usageBased =>
      '${AppFormat.digits(package.initialUnits ?? 0)} ${package.unitName ?? 'وحدة'}',
    PackageOfferType.singleVisit => 'زيارة واحدة',
  };

  @override
  Widget build(BuildContext context) {
    final validity = package.validityDays;
    final offerEnds = package.offerEndsAt;
    final availableUntil = package.availableUntil;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppDetailRowWidget(label: 'اللي فيها', value: _content),

        if (validity != null)
          AppDetailRowWidget(
            label: 'صالحة',
            value: '${AppFormat.digits(validity)} يوم من يوم الشرا',
          ),

        // الخدمات اللي تنفع عليها — من غيرها الباقة مش قابلة للحكم.
        if (package.services.isNotEmpty) ...<Widget>[
          SizedBox(height: AppSpacing.s16.h),
          Text('تنفع على', style: AppTextStyles.caption),
          SizedBox(height: AppSpacing.s8.h),
          Wrap(
            spacing: AppSpacing.s8.w,
            runSpacing: AppSpacing.s8.h,
            children: <Widget>[
              // ⚠ `AppPillWidget` مش `AppChipWidget` — الشيب حاجة تتختار
              // (بتاخد `isSelected` و`onTap`)، ودي أسماء بتتقرا وبس.
              for (final service in package.services)
                AppPillWidget(label: service.name),
            ],
          ),
        ],

        SizedBox(height: AppSpacing.s16.h),
        AppDashedDividerWidget(),
        SizedBox(height: AppSpacing.s16.h),

        // ⚠ **`Wrap` مش `Row`.** «السعر» كلمة ماتتقطعش والرقم أكبر خط في
        // الورقة — قص أي واحد فيهم خسارة، فعند مقياس ١٫٣ الرقم بينزل سطر
        // تحت بدل ما الصف يفيض.
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.s8.w,
            runSpacing: AppSpacing.s4.h,
            children: <Widget>[
              Text('السعر', style: AppTextStyles.bodyMd),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (package.hasOffer) ...<Widget>[
                    DiscountPriceWidget(amount: package.basePrice),
                    SizedBox(width: AppSpacing.s8.w),
                  ],
                  Text(
                    AppFormat.money(package.effectivePrice),
                    style: AppTextStyles.numeric(20),
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),

        // **العرض له آخر يوم.** خصم من غير تاريخ بيقرا سعر دايم، واللي
        // ترجع الشهر الجاي تلاقي رقم تاني وتحس إنها اتخدعت.
        if (package.hasOffer && offerEnds != null) ...<Widget>[
          SizedBox(height: AppSpacing.s8.h),
          AppPillWidget(
            label:
                'وفّرت ${AppFormat.money(package.savings)} · العرض لحد '
                '${AppFormat.fullDate(offerEnds)}',
            tone: AppPillTone.positive,
          ),
        ],

        if (availableUntil != null) ...<Widget>[
          SizedBox(height: AppSpacing.s8.h),
          Text(
            'معروضة لحد ${AppFormat.fullDate(availableUntil)}',
            style: AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        SizedBox(height: AppSpacing.s16.h),
        Text(
          'الباقة بتتشتري من ${package.branchName} — كلّم الفرع أو اسأل في '
          'الريسبشن.',
          style: AppTextStyles.caption,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
