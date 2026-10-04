import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/core/utils/styles.dart';
import 'package:waqty_user_application/core/widgets/button_widget.dart';
import 'package:waqty_user_application/features/account/language/data/models/language_option_model.dart';
import 'package:waqty_user_application/features/account/language/logic/language_cubit.dart';
import 'package:waqty_user_application/features/account/language/logic/language_state.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguageCubit, LanguageState>(
      listener: (context, state) {
        if (state is LanguageSavedState) context.pop();
      },
      builder: (context, state) {
        final cubit = LanguageCubit.get(context);
        return Scaffold(
          backgroundColor: AppColors.pageColor,
          bottomNavigationBar: _SaveLanguageFooter(cubit: cubit),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 130.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'اللغة',
                                textAlign: TextAlign.right,
                                style: TextStyles.font20greyColor900W600
                                    .copyWith(height: 1.3),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'يقلب الواجهة كلها فورًا',
                                textAlign: TextAlign.right,
                                style: TextStyles.font12greyColor500W400,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _BackButton(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                    child: Column(
                      children: [
                        _LanguageOptionCard(
                          option: const LanguageOptionModel(
                            title: 'العربية',
                            subtitle: 'من اليمين لليسار',
                            label: 'العربية',
                            languageCode: 'ar',
                            direction: ui.TextDirection.rtl,
                          ),
                          selected: cubit.selectedLanguageCode == 'ar',
                          onTap: () => cubit.changeLanguage('ar'),
                        ),
                        SizedBox(height: 8.h),
                        _LanguageOptionCard(
                          option: const LanguageOptionModel(
                            title: 'الإنجليزية',
                            subtitle: 'من اليسار لليمين',
                            label: 'English',
                            languageCode: 'en',
                            direction: ui.TextDirection.ltr,
                          ),
                          selected: cubit.selectedLanguageCode == 'en',
                          onTap: () => cubit.changeLanguage('en'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                    child: _InfoNote(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: context.pop,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.18),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
              spreadRadius: -8.r,
            ),
            BoxShadow(
              color: AppColors.greyColor900.withValues(alpha: 0.06),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.greyColor900,
          size: 17.sp,
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  final LanguageOptionModel option;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenColor505 : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? AppColors.greenColor500 : Colors.transparent,
            width: selected ? 1.2 : 0,
          ),
        ),
        child: Directionality(
          textDirection: option.direction,
          child: Row(
            children: [
              _RadioMarker(selected: selected),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: option.direction == ui.TextDirection.rtl
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      textAlign: option.direction == ui.TextDirection.rtl
                          ? TextAlign.right
                          : TextAlign.left,
                      style:
                          (selected
                                  ? TextStyles.font16greyColor900Weight600
                                  : TextStyles.font16greyColor900Weight400)
                              .copyWith(height: 1.3),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      option.subtitle,
                      textAlign: option.direction == ui.TextDirection.rtl
                          ? TextAlign.right
                          : TextAlign.left,
                      style: TextStyles.font12greyColor500W400,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 62.w,
                child: Text(
                  option.label,
                  textAlign: option.direction == ui.TextDirection.rtl
                      ? TextAlign.left
                      : TextAlign.right,
                  style: TextStyles.font12greyColor500W600.copyWith(
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioMarker extends StatelessWidget {
  final bool selected;

  const _RadioMarker({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: selected ? AppColors.greenColor500 : AppColors.whiteColor,
        shape: BoxShape.circle,
        border: selected
            ? null
            : Border.all(color: AppColors.greyColor200, width: 1.5),
      ),
      child: selected
          ? Icon(Icons.check_rounded, color: AppColors.whiteColor, size: 14.sp)
          : null,
    );
  }
}

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xffF1F0EB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'الأسماء والعناوين تبقى كما كتبها الفرع — لا نترجم أسماء الأماكن ولا الخدمات.',
              textAlign: TextAlign.right,
              style: TextStyles.font12greyColor500W400.copyWith(height: 1.65),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.greyColor500,
            size: 16.sp,
          ),
        ],
      ),
    );
  }
}

class _SaveLanguageFooter extends StatelessWidget {
  final LanguageCubit cubit;

  const _SaveLanguageFooter({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 26.h),
      decoration: BoxDecoration(
        color: AppColors.pageColor.withValues(alpha: 0.94),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor900.withValues(alpha: 0.06),
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ButtonWidget(
        isLoading: false,
        borderRadius: 999,
        buttonHeight: 52.h,
        buttonText: 'احفظ',
        backGroundColor: AppColors.greyColor900,
        borderColor: AppColors.greyColor900,
        textStyle: TextStyles.font16whiteColorWeight600,
        onPressed: () async {
          final locale = cubit.selectedLanguageCode == 'en'
              ? const Locale('en', 'US')
              : const Locale('ar', 'EG');
          await context.setLocale(locale);
          cubit.markSaved();
        },
      ),
    );
  }
}
