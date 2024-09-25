import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventsource/eventsource.dart';

import 'package:provider/provider.dart';
import 'package:wiset_project/roomPainter.dart';
import 'package:wiset_project/sunPathPainter.dart';
import 'levelProvider.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String sunset = "";
  String sunrise = "";
  double temperatureDataAvg = 0;
  double sunAngle = 0.0;
  int currentLevel = 2;

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

    final url = 'http://15.164.63.241:8080/sse?x=$hitMapCol&y=$hitMapRow';

    try {
      // EventSource 객체를 사용하여 SSE 스트림 연결
      EventSource eventSource = await EventSource.connect(url);

      // 이벤트 수신 대기
      eventSource.listen((Event event) {
        if (event.data != null) {
          final Map<String, dynamic> jsonResponse = json.decode(event.data!);

          // UI 업데이트
          setState(() {
            temperatureData = jsonResponse['illum']
                .map((row) => row.map((item) => item.toDouble()).toList())
                .toList() ?? temperatureData;
            temperatureDataAvg = (jsonResponse['avg'] ?? temperatureDataAvg) as double;
          });
        }
      });
    } catch (e) {
      print('Failed to connect to SSE stream: $e');
    }
  }

  Future<void> fetchSunriseSunset() async {
    final url = 'http://15.164.63.241:8080/sun/riseAndSet';
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
    List<List<int>> hitMapLevel = [[4, 3], [7, 5], [10, 7]];
    ScrollController scrollController = ScrollController();

    return Scaffold(
      body: Consumer<LevelProvider>(
        builder: (context, levelProvider, child) {
          fetchHitMapAntAvg(hitMapLevel[levelProvider.level - 1]);

          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Positioned(
                      top: change(false, 10),
                      left: change(true, 40),
                      child: CustomPaint(
                        size: Size(change(true, 335), change(false, 300)),
                        painter: SunPathPainter(sunrise: sunrise, sunset: sunset),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.align_vertical_bottom_outlined),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('평균 조도값'),
                              Text(temperatureDataAvg.toString()),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.sunny),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('오늘의 일출 시간'),
                                    Text(sunrise),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.sunny),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('오늘의 일몰 시간'),
                                    Text(sunset),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
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
