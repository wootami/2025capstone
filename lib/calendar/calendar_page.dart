import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  void _addEvent() {
    if (_selectedDay != null) {
      setState(() {
        final events = _events[_selectedDay!] ?? [];
        events.add('새 일정');
        _events[_selectedDay!] = events;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('캘린더')),
      body: SingleChildScrollView( // 스크롤 가능하게 만듦
        child: Column(
          children: [
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: DateTime.now(),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  // 날짜 선택 로직
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                // 일정 추가 로직
              },
              child: Text('일정 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
