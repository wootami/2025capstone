import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../api_key.dart';

class WeatherPage {
  final String serviceKey = ApiKeys.kmaServiceKey;

  Future<String> fetchShortTermWeather(DateTime selectedDate) async {
    final baseDate = DateFormat('yyyyMMdd').format(DateTime.now());
    final baseTime = '0500'; // 기준 시간 (예: 0500 = 오전 5시)
    final nx = '91'; // 경남 진주 가좌동 좌표 (예: 91, 75)
    final ny = '75';

    final url =
        'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst'
        '?serviceKey=$serviceKey'
        '&pageNo=1&numOfRows=1000'
        '&dataType=JSON'
        '&base_date=$baseDate'
        '&base_time=$baseTime'
        '&nx=$nx&ny=$ny';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['response']['body']['items']['item'];

        final selectedDateStr = DateFormat('yyyyMMdd').format(selectedDate);
        final weatherList = items.where((item) =>
        item['fcstDate'] == selectedDateStr &&
            (item['category'] == 'TMP' || item['category'] == 'SKY')).toList();

        if (weatherList.isEmpty) return '해당 날짜의 날씨 정보가 없어요.';

        String result = '📅 ${selectedDateStr} 날씨 정보\n';
        for (var item in weatherList) {
          result += '${item['fcstTime']}시 - ${item['category']}: ${item['fcstValue']}\n';
        }
        return result;
      } else {
        return '❌ 오류: ${response.statusCode}';
      }
    } catch (e) {
      return '❌ 예외 발생: $e';
    }
  }
}
