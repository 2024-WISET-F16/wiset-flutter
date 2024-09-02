import 'package:flutter/material.dart';
import 'navigation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Light AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NavigationPage(), // NavigationPage로 시작
    );
  }
}
