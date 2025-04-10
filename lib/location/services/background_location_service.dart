import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/location_record.dart';

class BackgroundLocationService {
  static const String taskName = 'locationTracking';
  static const Duration _minimumStayDuration = Duration(minutes: 15);
  static Position? _lastPosition;
  static DateTime? _stayStartTime;

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
    await _initializeNotifications();
  }

  static Future<void> _initializeNotifications() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> startBackgroundTracking() async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  static Future<void> stopBackgroundTracking() async {
    await Workmanager().cancelByUniqueName(taskName);
  }

  static Future<void> _saveLocation(
    double latitude,
    double longitude,
    Duration stayDuration,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const String locationKey = 'location_records';
      
      LocationRecord record = LocationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        latitude: latitude,
        longitude: longitude,
        address: '위치 정보',
        visitTime: _stayStartTime!,
        stayDuration: stayDuration,
        placeName: '위치 정보 가져오는 중...',
      );

      List<String> records = prefs.getStringList(locationKey) ?? [];
      records.add(jsonEncode(record.toJson()));
      await prefs.setStringList(locationKey, records);

      // 알림 표시
      await _showNotification(record);
    } catch (e) {
      print('백그라운드 위치 저장 오류: $e');
    }
  }

  static Future<void> _showNotification(LocationRecord record) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'location_tracking',
      '위치 추적',
      importance: Importance.low,
      priority: Priority.low,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      '새로운 위치 기록',
      '${record.address}에서 ${record.stayDuration.inMinutes}분 동안 머물렀습니다.',
      platformChannelSpecifics,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return true;
      }

      // 위치 서비스 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return true;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (BackgroundLocationService._lastPosition == null) {
        BackgroundLocationService._lastPosition = position;
        BackgroundLocationService._stayStartTime = DateTime.now();
      } else {
        // 이전 위치와 현재 위치의 거리 계산
        double distance = Geolocator.distanceBetween(
          BackgroundLocationService._lastPosition!.latitude,
          BackgroundLocationService._lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // 100미터 이상 이동했을 경우 새로운 위치로 인식
        if (distance > 100) {
          if (BackgroundLocationService._stayStartTime != null) {
            Duration stayDuration =
                DateTime.now().difference(BackgroundLocationService._stayStartTime!);
            if (stayDuration >= BackgroundLocationService._minimumStayDuration) {
              // 15분 이상 머물렀던 위치 저장
              await BackgroundLocationService._saveLocation(
                BackgroundLocationService._lastPosition!.latitude,
                BackgroundLocationService._lastPosition!.longitude,
                stayDuration,
              );
            }
          }
          BackgroundLocationService._lastPosition = position;
          BackgroundLocationService._stayStartTime = DateTime.now();
        }
      }
    } catch (e) {
      print('백그라운드 위치 추적 오류: $e');
    }

    return true;
  });
} 