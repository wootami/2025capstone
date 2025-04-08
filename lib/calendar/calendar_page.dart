import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../weather/weather_page.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _weatherInfo = '날짜를 선택하면 날씨를 보여줄게요 ☁️';

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _weatherInfo = '날씨 정보를 불러오는 중이에요...';
    });

    String info = await WeatherPage().fetchShortTermWeather(selectedDay);
    setState(() {
      _weatherInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('캘린더')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _weatherInfo,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
