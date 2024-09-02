import 'dart:math';
import 'package:flutter/material.dart';

class SunPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // 반원을 그리기 (반원의 시작은 자정 00:00, 끝은 자정 24:00)
    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        pi, // 반원의 시작 각도
        pi, // 반원의 길이 (180도)
        false,
      );

    canvas.drawPath(path, paint);

    // 현재 시간을 기준으로 해의 각도 계산
    final sunAngle = _calculateSunAngle();

    // 해의 위치 계산
    final sunX = center.dx + radius * cos(sunAngle - pi);
    final sunY = center.dy + radius * sin(sunAngle - pi);

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

  // 현재 시간을 기준으로 해의 각도를 계산하는 함수
  double _calculateSunAngle() {
    final DateTime currentTime = DateTime.now();
    final int hours = currentTime.hour;
    final int minutes = currentTime.minute;
    final int seconds = currentTime.second;

    // 하루의 총 시간(초) 계산
    final int totalSecondsInDay = 24 * 60 * 60;

    // 현재 시간(초) 계산
    final int currentSeconds = hours * 60 * 60 + minutes * 60 + seconds;

    // 현재 시간을 기준으로 각도 계산 (자정이 0도, 정오가 pi / 2, 자정이 다시 pi)
    final double angle = pi * (currentSeconds / totalSecondsInDay);

    return angle; // 반원에서의 각도를 위해 (0도에서 pi로 이동)
  }
}
