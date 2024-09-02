import 'dart:math';

import 'package:flutter/material.dart';

class SunPathPainter extends CustomPainter {
  final double sunAngle;

  SunPathPainter({required this.sunAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;

    final double radius = size.width / 2;

    // 반원을 그리기
    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        pi, // 반원의 시작 각도
        pi, // 반원의 길이
        false,
      );

    canvas.drawPath(path, paint);

    // 해의 위치를 계산
    final sunX = radius + radius * cos(sunAngle);
    final sunY = radius + radius * sin(sunAngle);

    // 해 아이콘을 그리기
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.wb_sunny.codePoint),
        style: TextStyle(
          fontSize: 45.0,
          fontFamily: Icons.wb_sunny.fontFamily,
          color: Colors.yellow,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(sunX - textPainter.width / 2, sunY - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // 계속해서 해의 위치를 업데이트하기 위해 true로 설정
  }
}