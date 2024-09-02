import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int level = 2;
  double cellSizeWidth = 50;
  double cellSizeHeight = 50;

  List<List<int>> hitMapLevel = [
    [4, 3],
    [7, 5],
    [10, 7]
  ];

  // 화면 크기에 따라 사이즈를 조정하는 함수
  double change(bool isWidth, double size) {
    final mediaQueryData = MediaQuery.of(context);
    final deviceWidth = mediaQueryData.size.width;
    final deviceHeight = mediaQueryData.size.height;
    const double testDeviceWidth = 390.0;
    const double testDeviceHeight = 844.0;

    double scaleFactor =
    isWidth ? (deviceWidth / testDeviceWidth) : (deviceHeight / testDeviceHeight);

    return size * scaleFactor;
  }

  // 히트맵 데이터를 가져오는 함수 (예시)
  Future<void> fetchHitMapAntAvg(List<int> hitMapLevel) async {
    // 서버에서 데이터를 가져오는 로직을 여기에 작성
    // 예시: 서버 요청 후 상태 업데이트
    // await http.get(...);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Grid Size Setting'),
          Slider(
            value: level.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            label: hitMapLevel[level - 1][0].toString() +
                'x' +
                hitMapLevel[level - 1][1].toString(),
            onChanged: (double value) {
              setState(() {
                level = value.round();
                fetchHitMapAntAvg(hitMapLevel[level - 1]);
                cellSizeWidth =
                    change(true, 250 / hitMapLevel[level - 1][1]);
                cellSizeHeight =
                    change(false, 350 / hitMapLevel[level - 1][0]);
              });
            },
          ),
        ],
      )
    );
  }
}
