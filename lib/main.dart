import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int level = 2;
  String sunset = "";
  String sunrise = "";
  double temperatureDataAvg = 0;
  double sunAngle = 0.0;

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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();

    // 해의 위치를 업데이트하는 타이머 설정 (1분마다 갱신)
    Timer.periodic(Duration(minutes: 1), (Timer timer) {
      setState(() {
        _updateSunAngle();
      });
    });
  }

  void _initializeData() async {
    await Future.delayed(Duration(seconds: 1)); // 1초 지연 추가
    await fetchSunriseSunset();
    await fetchHitMapAntAvg([7, 5]); // 초기 데이터를 불러오기 위해 기본 값을 사용
    setState(() {
      cellSizeWidth = change(true, 50);
      cellSizeHeight = change(false, 50);
      isLoading = false; // 데이터 로딩이 완료되면 로딩 상태를 false로 변경
      _updateSunAngle(); // 초기 각도 설정
    });
  }

  void _updateSunAngle() {
    final now = DateTime.now();
    final sunriseTime = _parseTime(sunrise);
    final sunsetTime = _parseTime(sunset);

    if (now.isAfter(sunriseTime) && now.isBefore(sunsetTime)) {
      final totalDuration = sunsetTime.difference(sunriseTime).inMinutes;
      final currentDuration = now.difference(sunriseTime).inMinutes;
      sunAngle = pi * (currentDuration / totalDuration);
    } else {
      sunAngle = 0.0; // 해가 뜨지 않은 시간 또는 진 후에는 각도를 0으로 설정
    }
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, minute);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMainContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMainContent() {
    List<List<int>> hitMapLevel = [[4, 3], [7, 5], [10, 7]];
    ScrollController scrollController = ScrollController();

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget> [
              Positioned(
                top: change(false, 10),
                left: change(true, 40),
                child: CustomPaint(
                  size: Size(change(true, 335), change(false, 300)),
                  painter: SunPathPainter(sunAngle: sunAngle),
                ),
              ),
              SizedBox(
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 25),
            child: Column(
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
          ),
        ],
      ),
    );
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
    final mediaQueryData = MediaQuery.of(context);
    final deviceWidth = mediaQueryData.size.width;
    final deviceHeight = mediaQueryData.size.height;
    const double testDeviceWidth = 390.0;
    const double testDeviceHeight = 844.0;

    double scaleFactor = isWidth ? (deviceWidth / testDeviceWidth) : (deviceHeight / testDeviceHeight);

    return size * scaleFactor;
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
