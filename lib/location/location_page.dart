import 'package:flutter/material.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _currentLocation = '서울특별시';
  List<String> _recentLocations = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위치 설정'),
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
                  '현재 위치: $_currentLocation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    // 위치 새로고침 기능 구현 예정
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '최근 검색한 위치',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recentLocations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.location_on, color: Colors.blue[300]),
                  title: Text(_recentLocations[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _recentLocations.removeAt(index);
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _currentLocation = _recentLocations[index];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새로운 위치 검색 기능 구현 예정
        },
        child: Icon(Icons.add_location),
        backgroundColor: Colors.blue[300],
      ),
    );
  }
}
