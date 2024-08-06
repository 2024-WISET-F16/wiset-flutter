import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  int level = 1;
  String sunset = "";
  String sunrise = "";
  List<List<double>> temperatureData = [
    [732.5, 918.6, 1124.3, 990.4, 837.0],
    [704.3, 849.7, 1004.9, 885.8, 756.8],
    [640.4, 721.0, 803.9, 729.2, 652.3],
    [568.1, 623.7, 697.0, 688.5, 662.3],
    [501.2, 545.6, 620.8, 658.4, 665.2],
    [451.0, 465.1, 496.5, 528.5, 543.2],
    [431.1, 425.1, 423.2, 439.9, 452.5]
  ];

  final DraggableScrollableController draggableScrollableController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    fetchSunriseSunset();
  }

  Future<void> fetchSunriseSunset() async {
    final url = 'https://localhost:8080/sun/riseAndSet';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, String> jsonResponse = json.decode(response.body).cast<String, String>();
      setState(() {
        sunrise = jsonResponse['sunrise'] ?? "";
        sunset = jsonResponse['sunset'] ?? "";
      });
    } else {
      throw Exception('Failed to load sunrise and sunset times');
    }
  }

  void _resetScale() {
    setState(() {
      _scale = 1.0;
    });
  }

  void _showDialog(BuildContext context, double temperature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            content: Text('조도: ${temperature.toStringAsFixed(1)}'),
            actions: <Widget>[
              TextButton(
                child: Text('닫기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  double change(bool isWidth, double size) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double deviceWidth = mediaQueryData.size.width;
    final double deviceHeight = mediaQueryData.size.height;
    const double testDeviceWidth = 390.0;
    const double testDeviceHeight = 844.0;

    double scaleFactor = isWidth ? (deviceWidth / testDeviceWidth) : (deviceHeight / testDeviceHeight);

    return size * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final double cellSizeWidth = change(true, 50);
    final double cellSizeHeight = change(false, 50);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: change(false, 600),
            child: GestureDetector(
              onTap: () {
                draggableScrollableController.animateTo(
                  0.1,
                  duration: Duration(seconds: 1),
                  curve: Curves.elasticIn,
                );
              },
              onScaleStart: (ScaleStartDetails details) {
                _previousScale = _scale;
              },
              onScaleUpdate: (ScaleUpdateDetails details) {
                setState(() {
                  _scale = (_previousScale * details.scale).clamp(0.5, 3.0);
                });
              },
              onScaleEnd: (ScaleEndDetails details) {
                _previousScale = _scale;
              },
              child: Transform.scale(
                scale: _scale,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(change(true, 70), change(false, 150), 0, 0),
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return Column(
                            children: temperatureData.map((row) {
                              return Row(
                                children: row.map((temperature) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showDialog(context, temperature);
                                    },
                                    child: Container(
                                      width: cellSizeWidth,
                                      height: cellSizeHeight,
                                      color: getColorFromTemperature(temperature),
                                    ),
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size(change(true, 300), change(false, 300)),
                        painter: RoomPainter(
                          cellSize: 50,
                          firstCellOffset: Offset(change(true, 70), change(false, 150)),
                          change: change,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 90,
            child: FloatingActionButton(
              onPressed: _resetScale,
              tooltip: 'Reset',
              child: const Icon(Icons.refresh),
            ),
          ),
          Positioned(
            left: 20,
            top: change(false, 100),
            child: SizedBox(
              height: change(false, 260),
              child: RotatedBox(
                quarterTurns: 1,
                child: Slider(
                    value: level.toDouble(),
                    min: 1,
                    max: 3,
                    divisions: 2,
                    label: level.toString(),
                    onChanged: (double value) {
                      setState(() {
                        level = value.round();
                      });
                    }
                ),
              ),
            )
          ),
          DraggableScrollableSheet(
            controller: draggableScrollableController,
            initialChildSize: 0.09,
            minChildSize: 0.09,
            maxChildSize: 0.5,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.95),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 6,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.sunny),
                      title: Text('오늘의 일출 시간'),
                      subtitle: Text(sunrise),
                    ),
                    ListTile(
                      leading: Icon(Icons.sunny_snowing),
                      title: Text('오늘의 일몰 시간'),
                      subtitle: Text(sunset),
                    ),
                    ListTile(
                      leading: Icon(Icons.align_vertical_bottom_outlined),
                      title: Text('평균 조도값'),
                      subtitle: Text('486'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color getColorFromTemperature(double temperature) {
    if (temperature >= 1000) {
      return Colors.red;
    } else if (temperature >= 500) {
      return interpolateColor(Colors.blue, Colors.red, (temperature - 500) / 500);
    } else {
      return Colors.blue;
    }
  }

  Color interpolateColor(Color start, Color end, double factor) {
    return Color.fromARGB(
      255,
      (start.red + (end.red - start.red) * factor).round(),
      (start.green + (end.green - start.green) * factor).round(),
      (start.blue + (end.blue - start.blue) * factor).round(),
    );
  }
}

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

    // Draw walls
    // Back wall
    final backWallPath = Path()
      ..moveTo(firstCellOffset.dx, firstCellOffset.dy)
      ..lineTo(firstCellOffset.dx + term20width, firstCellOffset.dy - wallHeight)
      ..lineTo(firstCellOffset.dx + 5 * cellSizeWidth + term20width, firstCellOffset.dy - wallHeight)
      ..lineTo(firstCellOffset.dx + 5 * cellSizeWidth, firstCellOffset.dy)
      ..close();
    canvas.drawPath(backWallPath, paint);

    // Left wall
    final leftWallPath = Path()
      ..moveTo(firstCellOffset.dx, firstCellOffset.dy)
      ..lineTo(firstCellOffset.dx + term20width, firstCellOffset.dy - wallHeight)
      ..lineTo(firstCellOffset.dx + term20width, firstCellOffset.dy - wallHeight + 7 * cellSizeHeight)
      ..lineTo(firstCellOffset.dx, firstCellOffset.dy + 7 * cellSizeHeight)
      ..close();
    canvas.drawPath(leftWallPath, paint);

    // Right wall
    final rightWallPath = Path()
      ..moveTo(firstCellOffset.dx + 5 * cellSizeWidth, firstCellOffset.dy)
      ..lineTo(firstCellOffset.dx + 5 * cellSizeWidth + term20width, firstCellOffset.dy - wallHeight)
      ..lineTo(firstCellOffset.dx + term20width + 5 * cellSizeWidth, firstCellOffset.dy - wallHeight + 7 * cellSizeHeight) // Adjust perspective
      ..lineTo(firstCellOffset.dx + 5 * cellSizeWidth, firstCellOffset.dy + 7 * cellSizeHeight) // Adjust perspective
      ..close();
    canvas.drawPath(rightWallPath, paint);

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
