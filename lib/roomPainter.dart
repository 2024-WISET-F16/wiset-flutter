import 'dart:ui';

import 'package:flutter/material.dart';

class RoomPainter extends CustomPainter {
  final double cellSize;
  final Offset firstCellOffset;
  final double Function(bool, double) change;

  RoomPainter({required this.cellSize, required this.firstCellOffset, required this.change});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2.5;

    final cellSizeWidth = change(true, cellSize);
    final cellSizeHeight = change(false, cellSize);
    final wallHeight = change(false, 60.0); // 벽 높이
    final term20height = change(false, 20.0);
    final term20width = change(true, 20.0);

    // 뒤쪽 벽 그리기
    final backWallPath = Path()
      ..moveTo(firstCellOffset.dx, firstCellOffset.dy)
      ..lineTo(firstCellOffset.dx + term20width, firstCellOffset.dy - wallHeight)
      ..lineTo(firstCellOffset.dx + 5 * cellSizeWidth + term20width, firstCellOffset.dy - wallHeight)
      ..lineTo(firstCellOffset.dx + 5 * cellSizeWidth, firstCellOffset.dy)
      ..close();
    canvas.drawPath(backWallPath, paint);

    // 왼쪽 벽 그리기
    final leftWallPath = Path()
      ..moveTo(firstCellOffset.dx, firstCellOffset.dy)
      ..lineTo(firstCellOffset.dx + term20width, firstCellOffset.dy - wallHeight)
      ..lineTo(firstCellOffset.dx + term20width, firstCellOffset.dy - wallHeight + 7 * cellSizeHeight)
      ..lineTo(firstCellOffset.dx, firstCellOffset.dy + 7 * cellSizeHeight)
      ..close();
    canvas.drawPath(leftWallPath, paint);

    // 오른쪽 벽 그리기
    final rightWallPath = Path()
      ..moveTo(firstCellOffset.dx + 5 * cellSizeWidth, firstCellOffset.dy)
      ..lineTo(firstCellOffset.dx + 5 * cellSizeWidth + term20width, firstCellOffset.dy - wallHeight)
      ..lineTo(firstCellOffset.dx + term20width + 5 * cellSizeWidth, firstCellOffset.dy - wallHeight + 7 * cellSizeHeight) // 퍼스펙티브 조정
      ..lineTo(firstCellOffset.dx + 5 * cellSizeWidth, firstCellOffset.dy + 7 * cellSizeHeight) // 퍼스펙티브 조정
      ..close();
    canvas.drawPath(rightWallPath, paint);

    // 창문 그리기
    final windowPath = Path()
      ..moveTo(firstCellOffset.dx + cellSizeWidth, firstCellOffset.dy - term20height)
      ..lineTo(firstCellOffset.dx + cellSizeWidth + term20width / 2, firstCellOffset.dy - term20height * 2)
      ..lineTo(firstCellOffset.dx + cellSizeWidth * 4.3 + term20width / 2, firstCellOffset.dy - term20height * 2)
      ..lineTo(firstCellOffset.dx + cellSizeWidth * 4.3, firstCellOffset.dy - term20height)
      ..close();
    canvas.drawPath(windowPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
