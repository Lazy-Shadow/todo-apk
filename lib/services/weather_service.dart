import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,uv_index&hourly=temperature_2m,weather_code,precipitation_probability&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Return empty on error
    }
    return {};
  }

  Future<String> getLocationName(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'TodoApp/1.0'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['address']?['city'] ??
            data['address']?['town'] ??
            data['address']?['village'] ??
            'Unknown Location';
      }
    } catch (e) {
      // Return empty on error
    }
    return 'Unknown Location';
  }

  Map<String, dynamic> getWeatherInfo(int code) {
    if (code == 0) return {'desc': 'Clear sky', 'icon': 'sunny', 'color': 0xFFFFC107};
    if (code <= 3) return {'desc': 'Partly cloudy', 'icon': 'partly_cloudy_day', 'color': 0xFF64B5F6};
    if (code <= 48) return {'desc': 'Foggy', 'icon': 'foggy', 'color': 0xFF9E9E9E};
    if (code <= 67) return {'desc': 'Rainy', 'icon': 'rainy', 'color': 0xFF1976D2};
    if (code <= 77) return {'desc': 'Snowy', 'icon': 'ac_unit', 'color': 0xFF90CAF9};
    if (code <= 82) return {'desc': 'Rain showers', 'icon': 'shower', 'color': 0xFF42A5F5};
    if (code <= 99) return {'desc': 'Thunderstorm', 'icon': 'thunderstorm', 'color': 0xFF7B1FA2};
    return {'desc': 'Cloudy', 'icon': 'cloud', 'color': 0xFF757575};
  }
}
