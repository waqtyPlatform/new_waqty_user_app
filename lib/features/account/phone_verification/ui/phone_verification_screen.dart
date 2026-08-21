import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/spacing.dart';
import 'package:waqty_user_application/core/widgets/resend_code_widget.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/account/phone_verification/logic/phone_verification_cubit.dart';
import 'package:waqty_user_application/features/account/phone_verification/logic/phone_verification_state.dart';

/// **تأكيد رقم التليفون — الشاشة اللي بتوصّل العميلة بفلوسها.**
///
/// الريسبشن بيعمل العميلة من رقم تليفون. لو الرقم ده ما اترّبطش بحساب
/// المنصة، الباقة اللي دفعت فيها كاش **مش موجودة** بالنسبة للتطبيق. الشاشة
/// دي هي الربط.
///
/// ⚠ **مش شاشة OTP تالتة.** الخانات `AppPinCodeFieldWidget` من الكيت،
/// وإعادة الإرسال `ResendCodeWidget` من `core/widgets` — نفس اللي شاشات
/// التسجيل واستعادة الباسورد بيستخدموهم. اللي جديد هنا هو **النتيجة**:
/// السيرفر بيرجّع كام سجل اترّبط، والشاشة بتقول الرقم ده.
class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

/// ⚠ **`State` هنا لملكية الـcontrollers بس — مافيش `setState` ولا سطر.**
///
/// `TextEditingController` لازم حد يعمله ويتخلّص منه، وده دور `State`.
/// كل حالة الشاشة في [PhoneVerificationCubit].
class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _otp = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSemanticColors.page,
      body: SafeArea(
        child: BlocConsumer<PhoneVerificationCubit, PhoneVerificationState>(
          listener: (context, state) {
            // النجاح بيرجّع النتيجة للشاشة اللي نادت — هي اللي تقرر تعمل
            // إيه بيها (تعيد تحميل الباقات والحجوزات وتوري الباند).
            if (state is PhoneVerificationSucceeded) {
              Navigator.of(context).pop(state.result);
            }
          },
          builder: (context, state) {
            final cubit = PhoneVerificationCubit.get(context);
            final isCodeStep = cubit.step == PhoneVerificationStep.code;

            return ListView(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.pageGutter.w,
                end: AppSpacing.pageGutter.w,
                top: AppSpacing.s8.h,
                bottom: AppSpacing.screenBottom.h,
              ),
              children: <Widget>[
                AppScreenHeaderWidget(
                  title: 'أكّد رقم تليفونك',
                  onBack: () => Navigator.of(context).pop(),
                ),
                verticalSpace(AppSpacing.s16),

                Text(
                  isCodeStep
                      ? 'بعتنا كود على ${cubit.pendingPhone}'
                      : 'لو حجزت أو اشتريت باقة من الفرع، أكّد رقمك عشان '
                            'يظهروا هنا.',
                  style: AppTextStyles.bodyMd,
                ),
                verticalSpace(AppSpacing.s24),

                if (isCodeStep)
                  ..._codeStep(context, cubit, state)
                else
                  ..._phoneStep(context, cubit, state),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _phoneStep(
    BuildContext context,
    PhoneVerificationCubit cubit,
    PhoneVerificationState state,
  ) {
    final failed = state is PhoneVerificationFailed ? state : null;

    return <Widget>[
      AppFieldWidget(
        label: 'رقم التليفون',
        // **التعارض بيتعرض هنا مش في خانات الكود.**
        //
        // «الرقم ده مسجّل على حساب تاني» مالوش علاقة بالكود، وعرضه تحت
        // الخانات بيخلّي العميلة تعيد كتابة كود صح لحد ما تيأس.
        error: failed?.isConflict ?? false ? failed!.message : null,
        child: AppTextFormField(
          hintText: '01xxxxxxxxx',
          controller: _phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.telephoneNumber],
          onSubmitted: (value) => cubit.sendCode(value),
        ),
      ),

      if (failed != null && failed.field == null) ...<Widget>[
        verticalSpace(AppSpacing.s8),
        Text(
          failed.message,
          style: AppTextStyles.caption.copyWith(
            color: AppSemanticColors.dangerOnSoft,
          ),
        ),
      ],

      if (failed?.isConflict ?? false) ...<Widget>[
        verticalSpace(AppSpacing.s8),
        Text(
          'لو ده رقمك فعلاً، كلّم الدعم عشان يظبطوه.',
          style: AppTextStyles.caption,
        ),
      ],

      verticalSpace(AppSpacing.s24),
      AppButtonWidget(
        label: 'ابعت الكود',
        isLoading: state is PhoneVerificationSending,
        onPressed: state is PhoneVerificationSending
            ? null
            : () => cubit.sendCode(_phone.text),
      ),
    ];
  }

  List<Widget> _codeStep(
    BuildContext context,
    PhoneVerificationCubit cubit,
    PhoneVerificationState state,
  ) {
    final failed = state is PhoneVerificationFailed ? state : null;
    final isSubmitting = state is PhoneVerificationSubmitting;

    return <Widget>[
      AppPinCodeFieldWidget(
        length: 4,
        controller: _otp,
        autofocus: true,
        hasError: failed?.isOtpError ?? false,
        onCompleted: (value) => cubit.verify(value),
      ),

      if (failed != null) ...<Widget>[
        verticalSpace(AppSpacing.s8),
        Text(
          failed.message,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: AppSemanticColors.dangerOnSoft,
          ),
        ),
      ],

      verticalSpace(AppSpacing.s16),
      ResendCodeWidget(
        canResend: cubit.canResend,
        timerText: cubit.timerText,
        onResend: cubit.resend,
        resendLabel: 'ابعت الكود تاني',
        countdownPrefix: 'تقدر تطلب كود تاني بعد',
        countdownSuffix: '',
      ),

      verticalSpace(AppSpacing.s24),
      AppButtonWidget(
        label: 'أكّد',
        isLoading: isSubmitting,
        onPressed: isSubmitting ? null : () => cubit.verify(_otp.text),
      ),

      verticalSpace(AppSpacing.s12),
      AppButtonWidget(
        label: 'غيّر الرقم',
        variant: AppButtonVariant.ghost,
        onPressed: isSubmitting
            ? null
            : () {
                _otp.clear();
                cubit.restart();
              },
      ),
    ];
  }
}
