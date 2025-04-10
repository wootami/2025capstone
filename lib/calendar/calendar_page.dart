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
  String _currentTemp = '기온 정보를 불러오는 중...';
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final WeatherPage _weatherPage = WeatherPage();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadCurrentTemperature();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentTemperature() async {
    String temp = await _weatherPage.getCurrentTemperature();
    setState(() {
      _currentTemp = temp;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _weatherInfo = '날씨 정보를 불러오는 중이에요...';
    });

    String info = await _weatherPage.fetchShortTermWeather(selectedDay);
    setState(() {
      _weatherInfo = info;
    });
  }

  Widget _buildWeatherPage(String title, String content) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[300],
            ),
          ),
          SizedBox(height: 20),
          Text(
            content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('날씨 캘린더'),
        backgroundColor: Colors.blue[300],
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue[300],
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(color: Colors.red),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white),
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      _currentTemp,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[300],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _weatherInfo,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
