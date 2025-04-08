import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'calendar/calendar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '날씨 캘린더',
      home: CalendarPage(),
    );
  }
}
