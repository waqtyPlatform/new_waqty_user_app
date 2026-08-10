import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// صف الخدمة — **هو نفسه مدخل الحجز**.
///
/// القديم كان بيقول «Hair Cut / 11 types» وجنبه سهم، من غير سعر ومن غير
/// أي استجابة للضغط. وأهم من كده: صف التصنيف وصف الخدمة كان شكلهم واحد
/// بالظبط، فالعميل مش عارف أنهي واحد فيهم بيحجز.
///
/// دلوقتي: الخدمة الحقيقية معاها السعر والمدة وزرار «احجز».
/// التصنيف معاه عدد الخدمات وسهم — وبس.
///
/// ## ليه بطّل كارت
///
/// قايمة الخدمات كانت N سطح أبيض مرفوع ورا بعض بمسافة ٨ بينهم — يعني
/// عشر ظلال وعشر استدارات في نص الصفحة، وكل واحد فيهم بيقول «أنا جسم
/// منفصل». والشاشة دي فيها بؤرة واحدة هي الحجز، فالخدمات لازم تقرا
/// كعمود واحد بيتمسح بالعين مش كعشر حاجات بتتنافس.
///
/// الصف دلوقتي قاعد على الصفحة مباشرة ومفصول بخط شعري — و**شايل هامش
/// الصفحة جواه** ([AppRowWidget]). يعني اللي بينده مايحطش عليه `Padding`
/// ولا يحطه جوه `SliverPadding` بهامش أفقي، وإلا الهامش بيتحسب مرتين.
class ServiceProviderDetailsServiceRowWidget extends StatelessWidget {
  /// **الحسبة:** ١٢ حشوة فوق + ١٢ تحت (من [AppRowWidget]) = ٢٤، زائد ٤
  /// (`titleToSubtitle`) بين اسم الخدمة وسطر «المدة · السعر». **المجموع ٢٨.**
  static const double _fixedPart =
      AppSpacing.cardPadding * 2 + AppSpacing.titleToSubtitle;

  /// **الحسبة عند مقياس خط ١٫٠:**
  /// `bodyMdStrong` ١٤×١٫٥٠ = ٢١ · والسطر التاني ارتفاعه أطول حاجة فيه،
  /// وهي شارة المدة (`captionStrong` ١٦٫٨ + ٨ حشوة = ٢٤٫٨؛ السعر
  /// `cardTitle` ٢٢٫٤ أقصر منها). المجموع الحسابي **٤٥٫٨**.
  ///
  /// الرقم هنا **٤٩**: فلاتر بيقرّب ارتفاع كل سطر لأعلى وقت التشكيل،
  /// والحسبة الدقيقة كانت بتسيب **صفر فراغ** — فعند مقياس خط ١٫٣ الكسور
  /// المتراكمة كانت بتفيّض الصف ٤ بكسل. الفراغ الزيادة بيتوزّع في الصف
  /// (ارتفاعه مفروض)، فمالوش تكلفة — والناقص هو اللي بيفيض.
  static const double _textPart = 49;

  /// أرضية زرار «احجز»: **٥٠** من `outlinedButtonTheme` + ٢٤ حشوة = **٧٤**.
  ///
  /// الزرار مش نص من ناحية الارتفاع — ارتفاعه مفروض من الثيم ومابيكبرش
  /// مع مقياس الخط. فعند ١٫٠ هو الأطول، وبعد مقياس معيّن النص بيعدّيه.
  /// أرضية بدل ما نزوّد الرقم الثابت، عشان الجزء اللي بيكبر يفضل هو
  /// الجزء اللي فيه نص فعلاً.
  ///
  /// ⚠ **مش `touchTarget`.** ده كان بيدي ٦٨ والزرار بيرسم ٧٤ — فيضان ٦
  /// بكسل في قايمة خدمات **كل** مقدّم خدمة. `outlinedButtonTheme` في
  /// الكيت بيحط `Size(0, 50.h)` مش ٤٤، و[AppButtonWidget.height] هو
  /// نفس الـ٥٠ دي معلنة باسم — فالقراءة من هناك بتفضل صح لو الثيم اتغيّر.
  static const double _buttonFloor =
      AppButtonWidget.height + AppSpacing.cardPadding * 2;

  /// المصدر الوحيد للارتفاع — وصف التصنيف بياخده كمان.
  ///
  /// التصنيف سطر واحد وسهم، يعني طبيعته ٤٨. لو سبناه على طبيعته، اللستة
  /// بتطلع صفوف ٤٨ وصفوف ٦٨ متبادلة — وده كان الباج اللي الـ ٦٤ الثابت
  /// القديم اتحط عشانه.
  static double heightOf(BuildContext context) {
    final byText = AppSpacing.scaledHeight(
      context,
      fixed: _fixedPart,
      text: _textPart,
    );
    return byText < _buttonFloor ? _buttonFloor : byText;
  }

  final ServiceUiModel service;
  final VoidCallback onTap;

  /// آخر صف في القايمة بياخد `false` — الخط الشعري تحت آخر عنصر بيرسم
  /// حد لقايمة مالهاش حد.
  final bool showHairline;

  const ServiceProviderDetailsServiceRowWidget({
    super.key,
    required this.service,
    required this.onTap,
    this.showHairline = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppRowWidget(
      onTap: onTap,
      height: heightOf(context).h,
      showHairline: showHairline,
      // مفيش `leading`، فالخط الشعري بيبدأ من هامش الصفحة — تحت النص
      // بالظبط، وده الافتراضي بتاع [AppRowWidget].
      trailing: service.isCategory
          ? DirectionalChevronWidget(
              size: 24,
              color: AppSemanticColors.textTertiary,
            )
          // ارتفاع الـ ٤٤ نقطة جاي من `outlinedButtonTheme` في الثيم.
          : OutlinedButton(onPressed: onTap, child: const Text('احجز')),
      child: service.isCategory ? _categoryLabel() : _serviceLabel(),
    );
  }

  Widget _categoryLabel() => Text(
    '${service.name} · ${AppFormat.digits(MockServices.childrenCountOf(service.uuid))} خدمة',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppTextStyles.bodyMdStrong,
  );

  /// السعر تحت الاسم مع المدة. كان عمود تالت لوحده جنب الزرار، فالصف كان
  /// تلات أعمدة على عرض ٣٧٥ — والاسم بيتقص بعد ١٢ حرف.
  ///
  /// ## المدة بقت شارة والسعر بقى رقم
  ///
  /// الاتنين كانوا سطر رمادي واحد (`٤٥ دقيقة · من ٢٥٠ ج.م`) بنفس الوزن
  /// ونفس اللون. وهما **مش نفس النوع**: المدة قيد (بتخطط بيها يومك)،
  /// والسعر هو اللي بتقارن بيه بين خدمة وخدمة.
  ///
  /// الشارة بتدي المدة حدود فبتقرا كحقيقة، و`cardTitle` بيدي السعر وزن
  /// بيخليه ثاني أعلى صوت في الصف بعد الاسم.
  Widget _serviceLabel() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        service.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMdStrong,
      ),
      verticalSpace(AppSpacing.titleToSubtitle),
      Row(
        children: [
          AppPillWidget(
            label: AppFormat.duration(service.durationMinutes),
            icon: Icons.schedule_rounded,
          ),
          horizontalSpace(AppSpacing.s8),
          Flexible(
            child: Text(
              AppFormat.money(service.price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardTitle,
            ),
          ),
        ],
      ),
    ],
  );
}
