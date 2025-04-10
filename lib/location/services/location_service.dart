import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/location_record.dart';
import 'place_service.dart';

class LocationService {
  static const String _locationKey = 'location_records';
  static const Duration _minimumStayDuration = Duration(minutes: 15);
  Timer? _locationTimer;
  Position? _lastPosition;
  DateTime? _stayStartTime;
  final _locationController = StreamController<LocationRecord>.broadcast();

  Stream<LocationRecord> get locationStream => _locationController.stream;

  Future<void> startTracking() async {
    // 위치 권한 확인
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    // 위치 서비스가 활성화되어 있는지 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // 주기적으로 위치 업데이트
    _locationTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (_lastPosition == null) {
          _lastPosition = position;
          _stayStartTime = DateTime.now();
        } else {
          // 이전 위치와 현재 위치의 거리 계산
          double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          // 100미터 이상 이동했을 경우 새로운 위치로 인식
          if (distance > 100) {
            if (_stayStartTime != null) {
              Duration stayDuration = DateTime.now().difference(_stayStartTime!);
              if (stayDuration >= _minimumStayDuration) {
                // 15분 이상 머물렀던 위치 저장
                await _saveLocation(
                  _lastPosition!.latitude,
                  _lastPosition!.longitude,
                  stayDuration,
                );
              }
            }
            _lastPosition = position;
            _stayStartTime = DateTime.now();
          }
        }
      } catch (e) {
        print('위치 추적 오류: $e');
      }
    });
  }

  Future<void> _saveLocation(
    double latitude,
    double longitude,
    Duration stayDuration,
  ) async {
    try {
      // 장소 정보 가져오기
      final placemark = await PlaceService.getPlaceInfo(latitude, longitude);
      
      LocationRecord record = LocationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        latitude: latitude,
        longitude: longitude,
        address: placemark != null ? PlaceService.formatAddress(placemark) : '위치 정보',
        placeName: placemark != null ? PlaceService.getPlaceName(placemark) : '알 수 없는 장소',
        visitTime: _stayStartTime!,
        stayDuration: stayDuration,
        subLocality: placemark?.subLocality,
        locality: placemark?.locality,
        administrativeArea: placemark?.administrativeArea,
      );

      // 기존 기록 가져오기
      final prefs = await SharedPreferences.getInstance();
      List<String> records = prefs.getStringList(_locationKey) ?? [];
      
      // 새 기록 추가
      records.add(jsonEncode(record.toJson()));
      await prefs.setStringList(_locationKey, records);

      // 스트림으로 새 위치 알림
      _locationController.add(record);
    } catch (e) {
      print('위치 저장 오류: $e');
    }
  }

  Future<List<LocationRecord>> getLocationRecords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList(_locationKey) ?? [];
    
    return records
        .map((record) => LocationRecord.fromJson(jsonDecode(record)))
        .toList()
      ..sort((a, b) => b.visitTime.compareTo(a.visitTime));
  }

  void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _lastPosition = null;
    _stayStartTime = null;
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
} 