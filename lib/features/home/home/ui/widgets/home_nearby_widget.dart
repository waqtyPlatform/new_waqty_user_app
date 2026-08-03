import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/widgets/empty_state_widget.dart';
import 'package:waqty_user_application/core/widgets/provider_row_skeleton_widget.dart';
import 'package:waqty_user_application/core/widgets/provider_row_widget.dart';

/// «قريب منك» — قايمة رأسية من **صفوف**، مش كروت.
///
/// ## ليه الكارت اتشال
///
/// تلات كروت بيضا مرفوعة ورا بعض تحت لوح الحبر معناها تلات ظلال وتلات
/// استدارات ٢٠ بيقولوا «أنا جسم منفصل» — وهم في الحقيقة نفس النوع من
/// المحتوى في عمود واحد. [ProviderRowWidget] بيقعد على الصفحة مباشرة
/// ومفصول بخط شعري مزاح ٨٤ (تحت النص، مش من الحافة)، فالعين بتنزل على
/// عمود واحد بدل ما تقفز بين حدود.
///
/// الكارت فضل في الصف الأفقي («الأكثر طلبًا») — هناك هو فعلاً جسم منفصل
/// بيتسحب لوحده.
///
/// لو مفيش نتايج، بنعرض حالة فاضية فيها إجراء (نوسّع نطاق البحث) —
/// مش مساحة بيضا.
class HomeNearbyWidget extends StatelessWidget {
  final List<ProviderUiModel> providers;
  final bool isLoading;
  final ValueChanged<ProviderUiModel> onProviderTap;
  final VoidCallback onWidenSearch;

  const HomeNearbyWidget({
    super.key,
    required this.providers,
    required this.onProviderTap,
    required this.onWidenSearch,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // مفيش `verticalSpace` بين الـ skeletons ولا بين الصفوف — الصف
      // بيفصل نفسه بخط شعري. لو سبنا المسافة ١٢ كمان، القايمة المحمّلة
      // هتبقى **أطول ٢٤ بكسل** من قايمة التحميل والصفحة هتنطّ.
      return Column(
        children: List<Widget>.generate(
          3,
          (index) => ProviderRowSkeletonWidget(showHairline: index < 2),
        ),
      );
    }

    if (providers.isEmpty) {
      // من غير هامش صفحة عن قصد: [EmptyStateWidget] شايل ٣٢ أفقي بنفسه —
      // أكبر من الهامش ١٦ أصلًا، فلفّه في هامش تاني بيطلّعه ٤٨ ويضيّق
      // الرسالة على شاشة ٣٧٥ من غير سبب.
      return EmptyStateWidget(
        icon: Icons.location_off_outlined,
        title: 'مفيش أماكن قريبة',
        message: 'مفيش حاجة في النطاق الحالي — جرّب توسّعه',
        actionLabel: 'وسّع نطاق البحث',
        onAction: onWidenSearch,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        return ProviderRowWidget(
          provider: provider,
          onTap: () => onProviderTap(provider),
          // آخر صف من غير خط — خط شعري تحت آخر عنصر بيقرا كأن القايمة
          // مقطوعة في نصها.
          showHairline: index != providers.length - 1,
        );
      },
    );
  }
}
