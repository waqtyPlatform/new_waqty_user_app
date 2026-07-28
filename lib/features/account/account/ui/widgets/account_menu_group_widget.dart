import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/widgets/app_hairline_widget.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_menu_item_widget.dart';

/// مجموعة صفوف في قايمة الحساب — سطح واحد بفواصل جواه.
///
/// شاشة الحساب كانت خمس صفوف بيضا على خلفية بيضا من غير أي فصل: كثافة
/// المعلومة ٤٠٪ والباقي فراغ مالوش معنى. التجميع بيوصّلها ~٦٢٪ **ومن غير
/// ما نصغّر أي حاجة** — الصف لسه ٥٦ نقطة.
///
/// والفاصل بيتحط بين الصفوف بس، مش بعد الأخير — فمفيش خط سايب على حافة
/// الكارت.
///
/// ## دي الشاشة الوحيدة اللي الكارت فيها بيستاهل مكانه
///
/// القايمة المجمّعة **جسم محدود فعلاً**: الحدود بتقول «الخمس حاجات دول
/// مع بعض والباقي لأ». في الشاشات التانية الكارت كان بيحوّط عنصر واحد
/// مالوش زمايل — فبقى إطار حوالين لا حاجة.
class AccountMenuGroupWidget extends StatelessWidget {
  final List<AccountMenuItemWidget> items;

  const AccountMenuGroupWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // مفيش حشوة أفقية هنا — الصف شايل هامشه جواه، فالضغط والفاصل
    // بيوصلوا لحافة الكارت.
    return AppSurfaceWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            // `Divider` كان بيجيب سُمكه من الثيم: **١ بكسل منطقي**، اللي
            // على شاشة 3x بيتوزّع على تلات بكسلات بشفافية فبيطلع خط
            // مضبّب. الخط الشعري بيرسم بكسل فيزيائي واحد حاد.
            //
            // والإزاحة جاية من الصف نفسه، فلو الأيقونة كبرت بكرة الفاصل
            // بيتحرّك معاها. `EdgeInsetsDirectional` جوه الـ widget —
            // يعني بيبدأ من اليمين في العربي لوحده.
            if (i != items.length - 1)
              const AppHairlineWidget(
                indent: AccountMenuItemWidget.hairlineIndent,
              ),
          ],
        ],
      ),
    );
  }
}
