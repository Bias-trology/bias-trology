import 'package:flutter/material.dart';

import 'astrology/timezone_conversion.dart';
import 'screens/today_horoscope_screen.dart';

void main() {
  initializeTimeZoneDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '推し占い',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodayHoroscopeScreen(),
    );
  }
}
