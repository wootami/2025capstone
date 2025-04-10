import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceService {
  static Future<Placemark?> getPlaceInfo(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
      return null;
    } catch (e) {
      print('장소 정보 가져오기 오류: $e');
      return null;
    }
  }

  static String formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.name?.isNotEmpty == true) {
      addressParts.add(place.name!);
    }
    if (place.street?.isNotEmpty == true) {
      addressParts.add(place.street!);
    }
    if (place.locality?.isNotEmpty == true) {
      addressParts.add(place.locality!);
    }
    if (place.subLocality?.isNotEmpty == true) {
      addressParts.add(place.subLocality!);
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.subAdministrativeArea?.isNotEmpty == true) {
      addressParts.add(place.subAdministrativeArea!);
    }
    if (place.postalCode?.isNotEmpty == true) {
      addressParts.add(place.postalCode!);
    }
    if (place.country?.isNotEmpty == true) {
      addressParts.add(place.country!);
    }

    return addressParts.join(' ');
  }

  static String getPlaceName(Placemark place) {
    if (place.name?.isNotEmpty == true) {
      return place.name!;
    }
    if (place.street?.isNotEmpty == true) {
      return place.street!;
    }
    if (place.locality?.isNotEmpty == true) {
      return place.locality!;
    }
    return '알 수 없는 장소';
  }
} 