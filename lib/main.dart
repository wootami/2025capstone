import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 로케일 초기화용 패키지
import 'calendar/calendar_page.dart';
import 'diary/diary_page.dart';
import 'location/location_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await initializeDateFormatting('ko_KR'); // 한글 로케일 데이터 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '캘린더 앱',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 페이지 목록
  final List<Widget> _pages = [
    CalendarPage(),
    DiaryPage(),
    LocationPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '다이어리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: '위치',
          ),
        ],
      ),
    );
  }
}
