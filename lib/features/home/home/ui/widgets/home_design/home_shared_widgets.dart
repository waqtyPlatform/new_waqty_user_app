part of '../home_design_widgets.dart';

List<BoxShadow> _cardShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.03),
      blurRadius: 2.r,
      offset: Offset(0, 1.h),
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.16),
      blurRadius: 24.r,
      offset: Offset(0, 10.h),
      spreadRadius: -14.r,
    ),
  ];
}

List<BoxShadow> _deepShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.06),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.20),
      blurRadius: 28.r,
      offset: Offset(0, 12.h),
      spreadRadius: -14.r,
    ),
  ];
}

List<BoxShadow> _inkShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.25),
      blurRadius: 45.r,
      offset: Offset(0, 16.h),
      spreadRadius: -16.r,
    ),
  ];
}

List<BoxShadow> _tileShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.10),
      blurRadius: 16.r,
      offset: Offset(0, 6.h),
      spreadRadius: -10.r,
    ),
  ];
}

List<BoxShadow> _tileDarkShadow() {
  return [
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.05),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: AppColors.greyColor900.withValues(alpha: 0.18),
      blurRadius: 23.r,
      offset: Offset(0, 8.h),
      spreadRadius: -10.r,
    ),
  ];
}

String _homeText(BuildContext context, String key, String fallback) {
  final translated = context.tr(key);
  return translated == key ? fallback : translated;
}

class _HorizontalList extends StatelessWidget {
  final double height;
  final List<Widget> children;

  const _HorizontalList({required this.height, required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 10.h),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemCount: children.length,
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String rightText;
  final String leftText;
  final Color rightColor;
  final Color leftColor;
  final bool dark;

  const _StatusRow({
    required this.rightText,
    required this.leftText,
    required this.rightColor,
    required this.leftColor,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 10.w) / 2;
          return Stack(
            children: [
              PositionedDirectional(
                start: 0,
                top: 0,
                width: itemWidth,
                child: _DotLabel(label: rightText, color: rightColor),
              ),
              PositionedDirectional(
                end: 0,
                top: 0,
                width: itemWidth,
                child: _Badge(
                  label: leftText,
                  background: dark
                      ? AppColors.warningColor100.withValues(alpha: 0.14)
                      : AppColors.warningColor0,
                  color: leftColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String titleKey;
  final String subtitleKey;
  final String? thirdKey;
  final bool light;
  final bool compact;

  const _TextBlock({
    required this.titleKey,
    required this.subtitleKey,
    this.thirdKey,
    this.light = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = light ? AppColors.whiteColor : AppColors.greyColor900;
    final bodyColor = light
        ? AppColors.whiteColor.withValues(alpha: 0.62)
        : AppColors.greyColor500;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr(titleKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: TextStyles.font16greyColor900Weight600.copyWith(
            color: titleColor,
            height: 1.3,
          ),
        ),
        SizedBox(height: compact ? 1.h : 3.h),
        Text(
          context.tr(subtitleKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: TextStyles.font12greyColor500W400.copyWith(color: bodyColor),
        ),
        if (thirdKey != null)
          Text(
            context.tr(thirdKey!),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyles.font12greyColor500W400.copyWith(color: bodyColor),
          ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82.w,
      height: 82.w,
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.tr('home.today'),
            style: TextStyles.font12whiteColorWeight600.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.70),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '4:30',
            style: TextStyles.font32greyColor900Weight600.copyWith(
              color: AppColors.whiteColor,
              height: 1.1,
            ),
          ),
          Text(
            context.tr('home.pm'),
            style: TextStyles.font12whiteColorWeight600.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.70),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final double height;

  const _PillButton({
    required this.label,
    required this.color,
    required this.textColor,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.font12greyColor900Weight400.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const _Badge({
    required this.label,
    required this.background,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyles.font12greyColor500W600.copyWith(color: color),
      ),
    );
  }
}

class _DotLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _DotLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22.h,
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          PositionedDirectional(
            start: 12.w,
            end: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyles.font12greyColor500W600.copyWith(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final double size;

  const _RoundIcon({
    required this.color,
    required this.icon,
    required this.iconColor,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: size.sp),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool dark;

  const _CircleButton({required this.icon, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: dark
            ? AppColors.whiteColor.withValues(alpha: 0.10)
            : AppColors.sunkenColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: dark ? AppColors.whiteColor : AppColors.greyColor900,
        size: 18.sp,
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const _WhiteCard({
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.greyColor50),
        boxShadow: _cardShadow(),
      ),
      child: child,
    );
  }
}

class _PhotoBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;

  const _PhotoBox({this.width, this.height, this.size});

  @override
  Widget build(BuildContext context) {
    final boxWidth = size?.w ?? width;
    final boxHeight = size?.w ?? height;
    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffF5F5F5), Color(0xffD9D2D6), Color(0xff322935)],
        ),
      ),
    );
  }
}

class _SectionPadding extends StatelessWidget {
  final Widget child;
  final double top;

  const _SectionPadding({required this.child, this.top = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, top.h, 20.w, 0),
      child: child,
    );
  }
}
