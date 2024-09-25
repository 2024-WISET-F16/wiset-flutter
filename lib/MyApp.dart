import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'levelProvider.dart';
import 'themeProvider.dart';
import 'navigation.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Light AI',
      theme: themeProvider.isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(),
      home: NavigationPage(),
    );
  }
}
