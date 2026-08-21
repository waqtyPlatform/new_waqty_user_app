import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/account/account/logic/account_state.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_header_skeleton_widget.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_header_widget.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_theme_item_widget.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is LogoutSuccessState) {
          context.pushNamedAndRemoveUntil(
            Routes.loginScreen,
            predicate: (_) => false,
          );
        }
      },
      builder: (context, state) {
        final cubit = AccountCubit.get(context);

        if (state is AccountErrorState) {
          return Padding(
            padding: AppSpacing.page,
            child: AppErrorStateWidget(
              message: state.message,
              onRetry: cubit.getProfile,
            ),
          );
        }

        final account = cubit.account;

        return ListView(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.pageGutter.w,
            end: AppSpacing.pageGutter.w,
            // ٢٤ مش ٨ زي باقي التبويبات. الهوم والحجوزات بيبدأوا بصف كروم
            // (شريط علوي)، والكروم بيلزق في حافة الشاشة عادي. هنا أول حاجة
            // اسم بـ ٣٢sp — والبؤرة الملزوقة في شريط الحالة بتقرا غلطة
            // تخطيط مش قرار.
            top: AppSpacing.s24.h,
            bottom: AppSpacing.screenBottom.h,
          ),
          children: [
            if (account == null)
              const AccountHeaderSkeletonWidget()
            else
              AccountHeaderWidget(account: account),

            // **المجموعتين بقوا قسمين بعنوان.**
            //
            // كانوا كارتين مالهمش لابل، والمسافة ٢٤ بينهم كانت **الإشارة
            // الوحيدة** إنهم موضوعين مختلفين — الكومنت القديم كان بيقول
            // كده بالحرف. `AppMenuRowWidget` بتاع الكيت كارت لكل صف، فلو
            // سبناهم من غير عناوين كانوا هيبقوا ست كروت متساوية ومفيش أي
            // حاجة بتقول فين القسم بيخلص.
            //
            // العنوان بيقول اللي المسافة كانت بتلمّح له، و`AppSectionHeader`
            // **بيملك مسافته بنفسه** (`sectionBreak` فوق · `headerToContent`
            // تحت) — فمافيش `verticalSpace` مكتوب بالإيد بينهم خالص.
            const AppSectionHeaderWidget(title: 'حسابك'),

            // ⚠ **«بياناتي» لسه ميت.** مفيش `PUT /api/user/profile` في
            // الباك-إند أصلاً (المقدّم والموظف عندهم واحد، والعميل لأ).
            // شاشة تعديل مالهاش endpoint تحفظ فيه أوحش من صف ساكت.
            AppMenuRowWidget(
              icon: Icons.person_outline_rounded,
              title: 'بياناتي',
              onTap: () {},
            ),
            AppMenuRowWidget(
              icon: Icons.receipt_long_rounded,
              title: 'مدفوعاتي',
              onTap: () => context.pushNamed(Routes.paymentsScreen),
            ),
            // **«حجوزاتي» اتشالت — كانت مكررة وميتة.**
            //
            // فيه تبويب اسمه «الحجوزات» في الشريط تحت وشغّال. الصف ده كان
            // `onTap: () {}`، يعني بيوعد بنفس المكان ومايوصلش — والعميل
            // اللي يدوسه مرة بيتعلّم إن الشاشة دي مابتردش.
            const AppSectionHeaderWidget(title: 'الأبلكيشن'),

            // اللغة مكانها هنا.
            //
            // كانت على شاشة التسجيل بس — يعني أول ما خلّينا اللي عامل
            // دخول يفتح على الهوم، اللغة بقت مستحيل تتغير. فالصف ده
            // شرط أساسي مش رفاهية.
            //
            // القيمة بقت `subtitle` مش `trailingText`: صف الكيت بيحجز
            // مساحة السطر التاني **دايمًا** عشان الصفوف ماترقصش، فالقيمة
            // تحت اللابل مجانية — وعلى اليمين كانت بتزاحم السهم.
            AppMenuRowWidget(
              icon: Icons.language_rounded,
              title: 'اللغة',
              subtitle: context.locale.languageCode == 'ar'
                  ? 'العربية'
                  : 'English',
              onTap: () => _showLanguageSheet(context),
            ),
            // **المظهر — الطريق الوحيد للوضع الغامق.**
            //
            // الافتراضي «حسب الجهاز»، فمعظم الناس مش هيدخلوا هنا أصلاً.
            // الصف موجود للحالتين اللي النظام مابيغطّيهمش: حد عايز
            // الأبلكيشن غامق طول الوقت، وحد جهازه غامق بس عايزه فاتح.
            const AccountThemeItemWidget(),
            AppMenuRowWidget(
              icon: Icons.help_outline_rounded,
              title: 'المساعدة',
              onTap: () {},
            ),
            AppMenuRowWidget(
              icon: Icons.description_rounded,
              title: 'الشروط وسياسة الخصوصية',
              onTap: () {},
            ),

            verticalSpace(AppSpacing.s16),

            // **الخروج مابيصرّخش.**
            //
            // كان لوح كامل العرض بحد أحمر وخط ١٦ — يعني تاني أعلى صوت في
            // شاشة أعلى صوت فيها المفروض يكون الشخص، والفرق بينه وبين
            // الاسم القديم (٢٠) كان أربع نقط بس.
            //
            // والوزن ده كان بيحذّر من حاجة **مش خطيرة لسه**: الضغطة دي
            // بتفتح ورقة تأكيد، مش بتخرّجك. الصراخ مكانه الزرار الممتلي
            // جوه الورقة — هناك بس الضغطة بتنفّذ فعلاً.
            //
            // الأحمر على النص كفاية للوضوح، وهدف اللمس لسه كامل العرض
            // بارتفاع `touchTarget` — يعني رجع لورا من غير ما يصعب.
            TextButton(
              onPressed: () => _confirmLogout(context, cubit),
              style: TextButton.styleFrom(
                foregroundColor: AppSemanticColors.danger,
                minimumSize: Size(double.infinity, AppSpacing.touchTarget.r),
              ),
              child: Text(
                'تسجيل الخروج',
                style: AppTextStyles.bodyMdStrong.copyWith(
                  color: AppSemanticColors.danger,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// الورقة بترجّع اللغة المختارة، **والشاشة هي اللي بتطبّقها**.
  ///
  /// ده مبدأ `AppSheetWidget`: الورقة مابتناديش `Navigator.pop` ولا بتنفّذ
  /// الفعل من جواها. الترتيب هنا مش تفصيلة — `setLocale` بترمي الشجرة،
  /// فلو اتنادت والورقة لسه مفتوحة كان الـ `Navigator` اللي هي قاعدة فيه
  /// بيتحذف من تحتها.
  void _showLanguageSheet(BuildContext context) {
    const locales = [
      // الاسم باللغة نفسها — مش «Arabic» و«English».
      (label: 'العربية', locale: Locale('ar', 'EG')),
      (label: 'English', locale: Locale('en', 'US')),
    ];

    final current = context.locale.languageCode;

    AppSheetWidget.show<Locale>(
      context,
      title: 'اللغة',
      content: Builder(
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in locales)
              AppChoiceRowWidget(
                title: item.label,
                selected: current == item.locale.languageCode,
                style: AppChoiceStyle.radio,
                onTap: () => Navigator.of(sheetContext).pop(item.locale),
              ),
          ],
        ),
      ),
      actions: (_) => const [],
    ).then((picked) {
      if (picked != null && context.mounted) context.setLocale(picked);
    });
  }

  void _confirmLogout(BuildContext context, AccountCubit cubit) {
    AppSheetWidget.show<bool>(
      context,
      icon: Icons.logout_rounded,
      iconTone: AppSemanticColors.danger,
      title: 'تسجيل الخروج؟',
      message: 'هتحتاج تسجّل دخول تاني عشان تشوف حجوزاتك',
      actions: (sheetContext) => [
        AppButtonWidget(
          label: 'تسجيل الخروج',
          variant: AppButtonVariant.danger,
          onPressed: () => Navigator.of(sheetContext).pop(true),
        ),
        AppButtonWidget(
          label: 'رجوع',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    ).then((confirmed) {
      if (confirmed ?? false) cubit.logout();
    });
  }
}
