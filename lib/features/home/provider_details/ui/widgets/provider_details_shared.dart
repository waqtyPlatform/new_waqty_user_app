import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';

const pdInk = AppColors.greyColor900;
const pdSub = AppColors.greyColor500;
const pdGreen = AppColors.greenColor500;
const pdSoft = AppColors.greenColor505;
const pdPlate = Color(0xFFF1F0EB);
String pd(BuildContext context, String key, [List<String> args = const []]) =>
    context.tr('providerPage.$key', args: args);
TextStyle pdText([
  double size = 12,
  Color color = pdInk,
  FontWeight weight = FontWeight.w400,
]) => TextStyle(
  fontFamily: 'IBMPlexSansArabic',
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: 1.5,
  letterSpacing: 0,
);

class PdIcon extends StatelessWidget {
  final String file;
  const PdIcon(this.file, {super.key});
  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/figma/provider_details/$file.svg');
}

class PdCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final bool outlined;
  const PdCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.radius = 18,
    this.outlined = true,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: outlined ? Border.all(color: pdInk.withValues(alpha: .07)) : null,
      boxShadow: outlined
          ? [
              BoxShadow(
                color: pdInk.withValues(alpha: .05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ]
          : null,
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class PdHeading extends StatelessWidget {
  final String title, subtitle;
  const PdHeading(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: pdText(20, pdInk, FontWeight.w600)),
        Text(subtitle, style: pdText(12, pdSub)),
      ],
    ),
  );
}

class PdNote extends StatelessWidget {
  final String text;
  final bool green;
  const PdNote(this.text, {super.key, this.green = false});
  @override
  Widget build(BuildContext context) => PdCard(
    color: green ? pdSoft : pdPlate,
    outlined: false,
    radius: 16,
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PdIcon(green ? '259cf' : 'c02dd'),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: pdText(12, green ? pdGreen : pdSub))),
      ],
    ),
  );
}

class PdButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  const PdButton(this.label, {super.key, this.onPressed, this.dark = true});
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: dark ? pdInk : pdPlate,
      foregroundColor: dark ? Colors.white : pdInk,
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      textStyle: pdText(14),
    ),
    child: Text(label, textAlign: TextAlign.center),
  );
}

Future<void> pdSheet(BuildContext context, String title, Widget child) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.pageColor,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: pdText(20, pdInk, FontWeight.w600)),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
void pdUnavailable(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(pd(context, 'unavailable'))));
}
