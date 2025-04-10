import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../api_key.dart';

class WeatherPage {
  final String serviceKey = ApiKeys.kmaServiceKey;

  Future<String> getCurrentTemperature() async {
    final baseDate = DateFormat('yyyyMMdd').format(DateTime.now());
    final baseTime = '0500';
    final nx = '91';
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
        
        // 현재 시간에 가장 가까운 기온 데이터 찾기
        final now = DateTime.now();
        final currentHour = now.hour;
        
        final temperatureItems = items.where((item) => 
          item['category'] == 'TMP' && 
          item['fcstDate'] == baseDate
        ).toList();

        if (temperatureItems.isEmpty) return '기온 정보 없음';

        // 현재 시간과 가장 가까운 예보 시간 찾기
        String closestTime = temperatureItems[0]['fcstTime'];
        int minDiff = 24;
        
        for (var item in temperatureItems) {
          final fcstHour = int.parse(item['fcstTime'].substring(0, 2));
          final diff = (fcstHour - currentHour).abs();
          if (diff < minDiff) {
            minDiff = diff;
            closestTime = item['fcstTime'];
          }
        }

        final currentTemp = temperatureItems.firstWhere(
          (item) => item['fcstTime'] == closestTime
        )['fcstValue'];

        return '$currentTemp°C';
      } else {
        return '오류';
      }
    } catch (e) {
      return '오류';
    }
  }

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

        // 최고/최저 기온 계산
        final temperatures = weatherList
            .where((item) => item['category'] == 'TMP')
            .map((item) => int.parse(item['fcstValue']))
            .toList();
        final maxTemp = temperatures.reduce((a, b) => a > b ? a : b);
        final minTemp = temperatures.reduce((a, b) => a < b ? a : b);

        // 시간대별 날씨 정보 정리
        final Map<String, String> timeWeather = {};
        for (var item in weatherList) {
          if (item['category'] == 'SKY') {
            final time = item['fcstTime'];
            final skyCode = item['fcstValue'];
            String weatherEmoji = '☀️'; // 기본값

            // SKY 코드에 따른 날씨 이모지 설정
            switch (skyCode) {
              case '1': weatherEmoji = '☀️'; break; // 맑음
              case '2': weatherEmoji = '🌤️'; break; // 구름조금
              case '3': weatherEmoji = '☁️'; break; // 구름많음
              case '4': weatherEmoji = '☁️'; break; // 흐림
            }
            timeWeather[time] = weatherEmoji;
          }
        }

        // 결과 문자열 생성
        String result = '📅 ${selectedDateStr} 날씨 정보\n';
        result += '🌡️ 최고기온: ${maxTemp}°C  ❄️ 최저기온: ${minTemp}°C\n\n';
        result += '시간대별 날씨:\n';
        
        // 시간대별 날씨를 가로로 정렬
        final sortedTimes = timeWeather.keys.toList()..sort();
        String timeRow = '';
        for (var time in sortedTimes) {
          timeRow += '${time}시 ${timeWeather[time]}  ';
        }
        result += timeRow;

        return result;
      } else {
        return '❌ 오류: ${response.statusCode}';
      }
    } catch (e) {
      return '❌ 예외 발생: $e';
    }
  }
}
