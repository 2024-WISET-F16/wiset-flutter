import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themeProvider.dart'; // ThemeProvider 임포트
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

  // 선택된 버튼을 추적하기 위한 변수
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<LevelProvider>(
      builder: (context, levelProvider, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 다크 모드 스위치
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SwitchListTile(
                      title: Text(
                        "Dark Mode Setting",
                        style: TextStyle(fontSize: 18),
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Grid Size 설정 섹션
                Text(
                  'Grid Size Setting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                // 화면 너비에 맞춘 버튼들
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: selectedIndex == 0 ? Colors.white : Colors.black, backgroundColor: selectedIndex == 0 ? Colors.blue : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedIndex = 0;
                                levelProvider.level = 1;
                              });
                            },
                            child: Text('4x3'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: selectedIndex == 1 ? Colors.white : Colors.black, backgroundColor: selectedIndex == 1 ? Colors.blue : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedIndex = 1;
                                levelProvider.level = 2;
                              });
                            },
                            child: Text('7x5'),
                          ),
                        ),
                        SizedBox(width: 10), // 버튼 간격
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: selectedIndex == 2 ? Colors.white : Colors.black, backgroundColor: selectedIndex == 2 ? Colors.blue : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedIndex = 2;
                                levelProvider.level = 3;
                              });
                            },
                            child: Text('10x7'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
