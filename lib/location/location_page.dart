import 'package:flutter/material.dart';
import 'models/location_record.dart';
import 'services/location_service.dart';
import 'services/background_location_service.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final LocationService _locationService = LocationService();
  List<LocationRecord> _locationRecords = [];
  bool _isTracking = false;
  bool _isBackgroundTracking = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeBackgroundService();
    _loadLocationRecords();
    _getCurrentLocation();
    _locationService.locationStream.listen((record) {
      setState(() {
        _locationRecords.insert(0, record);
        _updateMarkers();
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _updateMarkers();
      });
    } catch (e) {
      print('현재 위치 가져오기 오류: $e');
    }
  }

  void _updateMarkers() {
    _markers.clear();
    
    // 현재 위치 마커 추가
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('current'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: '현재 위치'),
        ),
      );
    }

    // 방문 기록 마커 추가
    for (var record in _locationRecords) {
      _markers.add(
        Marker(
          markerId: MarkerId(record.id),
          position: LatLng(record.latitude, record.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: record.placeName,
            snippet: record.address,
          ),
        ),
      );
    }
  }

  Future<void> _initializeBackgroundService() async {
    await BackgroundLocationService.initialize();
  }

  Future<void> _loadLocationRecords() async {
    final records = await _locationService.getLocationRecords();
    setState(() {
      _locationRecords = records;
      _updateMarkers();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return '$hours시간 $minutes분';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('방문 기록'),
        backgroundColor: Colors.blue[300],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.blue[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '실시간 위치 추적',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _isTracking,
                      onChanged: (bool value) async {
                        if (value) {
                          await _locationService.startTracking();
                        } else {
                          _locationService.stopTracking();
                        }
                        setState(() {
                          _isTracking = value;
                        });
                      },
                      activeColor: Colors.blue[300],
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '백그라운드 위치 추적',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _isBackgroundTracking,
                      onChanged: (bool value) async {
                        if (value) {
                          await BackgroundLocationService.startBackgroundTracking();
                        } else {
                          await BackgroundLocationService.stopBackgroundTracking();
                        }
                        setState(() {
                          _isBackgroundTracking = value;
                        });
                      },
                      activeColor: Colors.blue[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                  ),
          ),
          Expanded(
            child: _locationRecords.isEmpty
                ? Center(
                    child: Text(
                      '아직 방문 기록이 없습니다.\n위치 추적을 시작하면 15분 이상 머무른 곳이 기록됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _locationRecords.length,
                    itemBuilder: (context, index) {
                      final record = _locationRecords[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.blue[300],
                          ),
                          title: Text(record.placeName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.address,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                DateFormat('yyyy년 MM월 dd일 HH:mm')
                                    .format(record.visitTime),
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '체류 시간: ${_formatDuration(record.stayDuration)}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () {
                              // 삭제 기능 구현 예정
                            },
                          ),
                          onTap: () {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(record.latitude, record.longitude),
                                15,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
