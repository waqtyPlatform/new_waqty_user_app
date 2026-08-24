import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';

/// اسم صاحب الحساب — **بؤرة شاشة الحساب**.
///
/// ## ليه الاسم طلع ٣٢
///
/// الشاشة دي كانت **مالهاش بؤرة خالص**: دايرة، وسطر ٢٠، وتحتيه مجموعتين
/// بيضا متطابقين. أعلى صوت فيها كان زرار الخروج. لما الشاشة اسمها «حسابك»،
/// أعلى صوت فيها لازم يكون **الشخص**، والباقي يترجع لورا.
///
/// ## ليه الدايرة اتشالت بدل ما تبقى [EntityAvatarWidget]
///
/// لوح الحرف في الأبلكيشن ده **مش صورة بديلة — هو الهوية**، وشغلته إنه
/// يفرّق محل عن عشرين محل في لستة. هنا مافيش غير شخص واحد، ومافيش حاجة
/// يتفرّق عنها.
///
/// وأهم من كده: اللوح ٦٤ جنب اسم ٣٢sp بيبقى **جسمين بنفس الوزن جنب بعض**
/// — وده بالظبط الباج اللي بنصلّحه، مش حله. زايد إن الحرف اللي في اللوح هو
/// أول حرف من الاسم اللي جنبه بالظبط، يعني نفس الجليف مرتين، واحدة منهم
/// زينة.
///
/// وكمان [AppEntityTint] بيوزّع أربع عائلات لونية على الأسماء بالمجموع —
/// فكان هيدّي صاحب الحساب «لون علامة تجارية» عشوائي وهو مش علامة تجارية.
///
/// ## الاسم سطر واحد
///
/// الارتفاع محجوز لسطر واحد عشان [AccountHeaderSkeletonWidget] يقدر
/// يطابقه، فالصفحة ماتنطّش لما الداتا توصل. الاسم الطويل بيتقص — والتليفون
/// تحته هو المُعرّف اللي مايتلبّسش أصلاً.
class AccountHeaderWidget extends StatelessWidget {
  /// `displayLg` ٣٢ × ١٫١٥ = **٣٦٫٨**.
  static const double _nameLine = 36.8;

  /// `caption` ١٢ × ١٫٤٠ = **١٦٫٨**.
  static const double _phoneLine = 16.8;

  /// المصدر الوحيد للارتفاع — **و`AccountHeaderSkeletonWidget` بيقراه من
  /// هنا**، فاختلافهم بقى مستحيل بنيويًا.
  ///
  /// الثابت هو المسافة بين السطرين بس (٤)؛ النص لوحده هو اللي بيكبر مع
  /// مقياس الخط. الإجمالي عند ١٫٠ = **٥٧٫٦**.
  static double heightOf(BuildContext context) => AppSpacing.scaledHeight(
    context,
    fixed: AppSpacing.titleToSubtitle,
    text: _nameLine + _phoneLine,
  );

  final AccountUiModel account;

  const AccountHeaderWidget({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          account.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.displayLg,
        ),
        verticalSpace(AppSpacing.titleToSubtitle),
        // `caption` مش `bodyMdMuted`: التليفون هنا مش معلومة العميل جاي
        // يقراها، هو **إثبات إن ده حسابه هو**. أول ما اتأكد، المفروض
        // يختفي من عينه.
        //
        // والأرقام هندية زي أي رقم تاني في الأبلكيشن — الرقم اللاتيني
        // الوحيد وسط شاشة عربية بيقرا داتا خام مش نص.
        Text(AppFormat.digits(account.phone), style: AppTextStyles.caption),
      ],
    );
  }
}
