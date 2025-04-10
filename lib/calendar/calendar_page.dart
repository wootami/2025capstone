import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../weather/weather_page.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final WeatherPage _weatherPage = WeatherPage();
  String _currentTemperature = '로딩 중...';
  String _weatherInfo = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final temperature = await _weatherPage.getCurrentTemperature();
    setState(() {
      _currentTemperature = temperature;
    });
  }

  Future<void> _loadWeatherInfo(DateTime date) async {
    final weatherInfo = await _weatherPage.fetchShortTermWeather(date);
    setState(() {
      _weatherInfo = weatherInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('캘린더'),
        backgroundColor: Colors.blue[300],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '현재 기온: $_currentTemperature',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadWeatherInfo(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  _weatherInfo.isEmpty ? '날짜를 선택하면 날씨 정보가 표시됩니다.' : _weatherInfo,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
