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
  int level = 2;
  String sunset = "";
  String sunrise = "";
  double temperatureDataAvg = 0;
  List<List<double>> temperatureData = [
    [732.5, 918.6, 1124.3, 990.4, 837.0],
    [704.3, 849.7, 1004.9, 885.8, 756.8],
    [640.4, 721.0, 803.9, 729.2, 652.3],
    [568.1, 623.7, 697.0, 688.5, 662.3],
    [501.2, 545.6, 620.8, 658.4, 665.2],
    [451.0, 465.1, 496.5, 528.5, 543.2],
    [431.1, 425.1, 423.2, 439.9, 452.5]
  ];
  double cellSizeWidth = 50;
  double cellSizeHeight = 50;

  final DraggableScrollableController draggableScrollableController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // 데이터 초기화를 위한 함수
  void _initializeData() async {
    await fetchSunriseSunset();
    await fetchHitMapAntAvg([7, 5]); // 초기 데이터를 불러오기 위해 기본 값을 사용
    setState(() {
      cellSizeWidth = change(true, 50);
      cellSizeHeight = change(false, 50);
    });
  }

  // 히트맵과 평균 데이터를 가져오는 함수
  Future<void> fetchHitMapAntAvg(List<int> hitMapLevel) async {
    final hitMapRow = hitMapLevel[0];
    final hitMapCol = hitMapLevel[1];

    final url = 'http://localhost:8080/grid?x=$hitMapCol&y=$hitMapRow';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        temperatureData = jsonResponse['illum']
            .map((row) => row.map((item) => item.toDouble()).toList())
            .toList() ?? temperatureData;
        temperatureDataAvg = (jsonResponse['avg'] ?? temperatureDataAvg) as double;
      });
    } else {
      throw Exception('Failed to load hitmap and hitmap avg');
    }
  }

  // 일출 및 일몰 시간을 가져오는 함수
  Future<void> fetchSunriseSunset() async {
    final url = 'http://localhost:8080/sun/riseAndSet';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        sunrise = jsonResponse['sunrise'] ?? "";
        sunset = jsonResponse['sunset'] ?? "";
      });
    } else {
      throw Exception('Failed to load sunrise and sunset times');
    }
  }

  // 스케일 초기화 함수
  void _resetScale() {
    setState(() {
      _scale = 1.0;
    });
  }

  // 조도 데이터를 보여주는 다이얼로그
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

  // 화면 크기에 따라 사이즈를 조정하는 함수
  double change(bool isWidth, double size) {
    final mediaQueryData = MediaQuery.of(context);
    final deviceWidth = mediaQueryData.size.width;
    final deviceHeight = mediaQueryData.size.height;
    const double testDeviceWidth = 390.0;
    const double testDeviceHeight = 844.0;

    double scaleFactor = isWidth ? (deviceWidth / testDeviceWidth) : (deviceHeight / testDeviceHeight);

    return size * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {//250 350
    List<List<int>> hitMapLevel = [[4, 3], [7, 5], [10, 7]];

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
                      label: hitMapLevel[level-1][0].toString()+'x'+hitMapLevel[level-1][1].toString(),
                      onChanged: (double value) {
                        setState(() {
                          level = value.round();
                          fetchHitMapAntAvg(hitMapLevel[level-1]);
                          setState(() {
                            cellSizeWidth = change(true, 250 / hitMapLevel[level-1][1]);
                            cellSizeHeight = change(false, 350 / hitMapLevel[level-1][0]);
                          });
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
                      offset: Offset(0, 3), // 그림자 위치 변경
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
                      subtitle: Text(temperatureDataAvg.toString()),
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

  // 온도에 따라 색상을 반환하는 함수
  Color getColorFromTemperature(double temperature) {
    if (temperature >= 1000) {
      return Colors.red;
    } else if (temperature >= 500) {
      return interpolateColor(Colors.blue, Colors.red, (temperature - 500) / 500);
    } else {
      return Colors.blue;
    }
  }

  // 두 색상 사이의 색상을 보간하는 함수
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
