import 'dart:math';
import 'package:flutter/material.dart';

class SunPathPainter extends CustomPainter {
  final String sunrise;
  final String sunset;

  SunPathPainter({required this.sunrise, required this.sunset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // 반원을 그리기 (해 뜨는 시간부터 해 지는 시간까지)
    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        pi, // 반원의 시작 각도
        pi, // 반원의 길이 (180도)
        false,
      );

    canvas.drawPath(path, paint);

    // 일출, 일몰 시간을 기준으로 해의 각도 계산
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

  // 해의 각도를 계산하는 함수 (일출, 일몰 시간 기반)
  double _calculateSunAngle() {
    final DateTime now = DateTime.now();
    final DateTime sunriseTime = _parseTime(sunrise);
    final DateTime sunsetTime = _parseTime(sunset);

    if (now.isBefore(sunriseTime) || now.isAfter(sunsetTime)) {
      return pi; // 해가 뜨지 않은 시간에는 해를 숨김
    }

    // 일출과 일몰 사이의 총 시간 계산
    final totalDaylightSeconds = sunsetTime.difference(sunriseTime).inSeconds;

    // 현재 시간이 일출 후 경과한 시간 계산
    final elapsedSeconds = now.difference(sunriseTime).inSeconds;

    // 경과 시간에 따라 방위각 계산 (0도에서 180도까지)
    final sunAngle = pi * (elapsedSeconds / totalDaylightSeconds);

    return sunAngle; // 방위각 반환
  }

  // 문자열로 받은 일출, 일몰 시간을 DateTime으로 변환하는 함수
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, minute);
  }
}
