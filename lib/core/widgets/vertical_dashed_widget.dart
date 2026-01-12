import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerticalDashedWidget extends StatelessWidget {
  final double height;
  final double space;

  const VerticalDashedWidget({
    required this.height,
    required this.space,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.w,
      height: double.infinity,
      child: CustomPaint(
        painter: VerticalDashedLinePainter(space: space, height: height),
      ),
    );
  }
}

class VerticalDashedLinePainter extends CustomPainter {
  final double height;
  final double space;

  VerticalDashedLinePainter({required this.height, required this.space});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.greyColro8D
      ..strokeWidth = 1.w
      ..strokeCap = StrokeCap.round;

    double dashHeight = height.h;
    double dashSpace = space.h;

    double startY = 10.0;
    double endY = size.height - 10;

    double currentY = startY;

    while (currentY < endY) {
      canvas.drawLine(
        Offset(0.0, currentY),
        Offset(0.0, currentY + dashHeight),
        paint,
      );
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
