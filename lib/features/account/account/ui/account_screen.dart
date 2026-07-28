import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/utils/app_text_styles.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/core/widgets/error_state_widget.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/account/account/logic/account_state.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_header_skeleton_widget.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_header_widget.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_menu_group_widget.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_menu_item_widget.dart';

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
            child: ErrorStateWidget(
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

            verticalSpace(AppSpacing.sectionBreak),

            // مجموعتين بدل خمس صفوف سايبة: **حسابك** و**الأبلكيشن**.
            // التقسيم ده مش شكلي — الصفوف الأولانية بتخص داتا العميل،
            // والتانية بتخص الأبلكيشن نفسه.
            AccountMenuGroupWidget(
              items: [
                AccountMenuItemWidget(
                  icon: Icons.person_outline_rounded,
                  label: 'بياناتي',
                  onTap: () {},
                ),
                AccountMenuItemWidget(
                  icon: Icons.event_note_outlined,
                  label: 'حجوزاتي',
                  onTap: () {},
                ),
              ],
            ),

            // ٢٤ مش ١٢. المجموعتين مالهمش لابل، فالمسافة بينهم هي **الإشارة
            // الوحيدة** إنهم موضوعين مختلفين. ١٢ (نفس مسافة الصفوف) كانت
            // بتخليهم يقروا كارت واحد مقطوع. و٤٠ كتير — ده مش فاصل أقسام،
            // الاتنين لسه «قايمة».
            verticalSpace(AppSpacing.s24),

            AccountMenuGroupWidget(
              items: [
                // اللغة مكانها هنا.
                //
                // كانت على شاشة التسجيل بس — يعني أول ما خلّينا اللي عامل
                // دخول يفتح على الهوم، اللغة بقت مستحيل تتغير. فالصف ده
                // شرط أساسي مش رفاهية.
                AccountMenuItemWidget(
                  icon: Icons.language_rounded,
                  label: 'اللغة',
                  trailingText: context.locale.languageCode == 'ar'
                      ? 'العربية'
                      : 'English',
                  onTap: () => _showLanguageSheet(context),
                ),
                AccountMenuItemWidget(
                  icon: Icons.help_outline_rounded,
                  label: 'المساعدة',
                  onTap: () {},
                ),
                AccountMenuItemWidget(
                  icon: Icons.description_rounded,
                  label: 'الشروط وسياسة الخصوصية',
                  onTap: () {},
                ),
              ],
            ),

            verticalSpace(AppSpacing.sectionBreak),

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
            ButtonWidget(
              isLoading: state is LogoutLoadingState,
              buttonText: 'تسجيل الخروج',
              fourGroundColor: AppSemanticColors.danger,
              textStyle: AppTextStyles.bodyMdStrong.copyWith(
                color: AppSemanticColors.danger,
              ),
              buttonHeight: AppSpacing.touchTarget.r,
              onPressed: () => _confirmLogout(context, cubit),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context) {
    // الخلفية والاستدارة ومقبض السحب كلهم جايين من `bottomSheetTheme`.
    // و`useSafeArea` بدل الـ SafeArea الداخلية — كده كل الـ sheets بتقعد
    // على نفس الهامش السفلي.
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.s16.w,
          end: AppSpacing.s16.w,
          top: AppSpacing.s8.h,
          bottom: AppSpacing.s16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اللغة', style: AppTextStyles.sectionHeader),
            verticalSpace(AppSpacing.s8),
            // الاسم باللغة نفسها — مش «Arabic» و «English».
            _languageTile(sheetContext, 'العربية', const Locale('ar', 'EG')),
            _languageTile(sheetContext, 'English', const Locale('en', 'US')),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(BuildContext context, String label, Locale locale) {
    final isSelected = context.locale.languageCode == locale.languageCode;

    // الحشوة والستايل جايين من `listTileTheme`.
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppSemanticColors.accent,
            )
          : null,
      onTap: () {
        context.setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }

  void _confirmLogout(BuildContext context, AccountCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.s16.w,
          end: AppSpacing.s16.w,
          top: AppSpacing.s8.h,
          bottom: AppSpacing.s16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تسجيل الخروج؟', style: AppTextStyles.sectionHeader),
            verticalSpace(AppSpacing.s4),
            Text(
              'هتحتاج تسجّل دخول تاني عشان تشوف حجوزاتك',
              style: AppTextStyles.caption,
            ),
            verticalSpace(AppSpacing.s16),
            ButtonWidget(
              isLoading: false,
              buttonText: 'تسجيل الخروج',
              backGroundColor: AppSemanticColors.danger,
              borderColor: AppSemanticColors.danger,
              textStyle: AppTextStyles.button,
              buttonHeight: 52.h,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                cubit.logout();
              },
            ),
            verticalSpace(AppSpacing.s8),
            // الحد الأدنى للمس جاي من `textButtonTheme` — مش محتاج SizedBox.
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(
                'رجوع',
                style: AppTextStyles.bodyMdStrong.copyWith(
                  color: AppSemanticColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
