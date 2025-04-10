class LocationRecord {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final String placeName;
  final DateTime visitTime;
  final Duration stayDuration;
  final String? subLocality;
  final String? locality;
  final String? administrativeArea;

  LocationRecord({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.placeName,
    required this.visitTime,
    required this.stayDuration,
    this.subLocality,
    this.locality,
    this.administrativeArea,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'placeName': placeName,
      'visitTime': visitTime.toIso8601String(),
      'stayDuration': stayDuration.inSeconds,
      'subLocality': subLocality,
      'locality': locality,
      'administrativeArea': administrativeArea,
    };
  }

  factory LocationRecord.fromJson(Map<String, dynamic> json) {
    return LocationRecord(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      placeName: json['placeName'],
      visitTime: DateTime.parse(json['visitTime']),
      stayDuration: Duration(seconds: json['stayDuration']),
      subLocality: json['subLocality'],
      locality: json['locality'],
      administrativeArea: json['administrativeArea'],
    );
  }
} 