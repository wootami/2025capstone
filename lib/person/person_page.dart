import 'package:flutter/material.dart';

class PersonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
        backgroundColor: Colors.blue[300],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              color: Colors.blue[50],
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[300],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '사용자 이름',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue[300]),
              title: Text('알림 설정'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 알림 설정 페이지로 이동
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.blue[300]),
              title: Text('언어 설정'),
              trailing: Text('한국어'),
              onTap: () {
                // 언어 설정 페이지로 이동
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode, color: Colors.blue[300]),
              title: Text('다크 모드'),
              trailing: Switch(
                value: false,
                onChanged: (bool value) {
                  // 다크 모드 설정
                },
                activeColor: Colors.blue[300],
              ),
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.blue[300]),
              title: Text('도움말'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 도움말 페이지로 이동
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue[300]),
              title: Text('앱 정보'),
              trailing: Text('v1.0.0'),
              onTap: () {
                // 앱 정보 페이지로 이동
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[300]),
              title: Text(
                '로그아웃',
                style: TextStyle(color: Colors.red[300]),
              ),
              onTap: () {
                // 로그아웃 처리
              },
            ),
          ],
        ),
      ),
    );
  }
}
