import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'levelProvider.dart';
import 'navigation.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LevelProvider()),
      ],
      child: MyApp(),
    ),
  );
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
