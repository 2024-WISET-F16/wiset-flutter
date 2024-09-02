import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'levelProvider.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<List<int>> hitMapLevel = [
    [4, 3],
    [7, 5],
    [10, 7]
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProvider>(
      builder: (context, levelProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Grid Size Setting'),
              Slider(
                value: levelProvider.level.toDouble(),
                min: 1,
                max: 3,
                divisions: 2,
                label: hitMapLevel[levelProvider.level - 1][0].toString() + 'x' +
                  hitMapLevel[levelProvider.level - 1][1].toString(),
                onChanged: (double value) {
                  levelProvider.level = value.round();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
