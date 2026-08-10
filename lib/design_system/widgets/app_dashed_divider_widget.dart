import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/app_semantic_colors.dart';

/// فاصل منقّط.
///
/// منقول من `employee-app/lib/core/widgets/horizontal_dashed_widget.dart`
/// — **صفر ارتباط بالتطبيق، وعنصر هوية حقيقي** (بيفصل الإجمالي عن البنود
/// في قسيمة الراتب، فبيقرا «قصاصة» مش «كارت»).
///
/// التغيير الوحيد: اللون من التوكن بدل ما يكون ثابت، والسُمك بيتقاس
/// بالبكسل الفيزيائي زي [AppHairlineWidget].
class AppDashedDividerWidget extends StatelessWidget {
  const AppDashedDividerWidget({
    this.dash = 4,
    this.gap = 4,
    this.color,
    this.thickness,
    super.key,
  });

  /// طول الشرطة.
  final double dash;

  /// المسافة بين شرطة وشرطة.
  final double gap;

  final Color? color;

  /// `null` = بكسل فيزيائي واحد.
  final double? thickness;

  @override
  Widget build(BuildContext context) {
    final resolved = thickness ?? (1 / MediaQuery.devicePixelRatioOf(context));

    return SizedBox(
      width: double.infinity,
      height: resolved,
      child: CustomPaint(
        painter: _DashedPainter(
          dash: dash.w,
          gap: gap.w,
          color: color ?? AppSemanticColors.border,
          thickness: resolved,
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter({
    required this.dash,
    required this.gap,
    required this.color,
    required this.thickness,
  });

  final double dash;
  final double gap;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final step = dash + gap;
    if (step <= 0) return;

    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dash).clamp(0.0, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color ||
      old.dash != dash ||
      old.gap != gap ||
      old.thickness != thickness;
}
