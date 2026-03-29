import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic> _weatherData = {};
  String _locationName = 'Detecting location...';
  bool _isLoading = true;
  double? _lat;
  double? _lon;

  Map<String, dynamic> get weatherData => _weatherData;
  String get locationName => _locationName;
  bool get isLoading => _isLoading;
  double? get lat => _lat;
  double? get lon => _lon;

  Future<void> init() async {
    await _getLocation();
  }

  Future<void> _getLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationName = 'Location services disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationName = 'Location permission denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationName = 'Location permission permanently denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      _lat = position.latitude;
      _lon = position.longitude;

      _locationName = await _weatherService.getLocationName(_lat!, _lon!);
      await fetchWeather();
    } catch (e) {
      _locationName = 'Unable to get location';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeather() async {
    if (_lat == null || _lon == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _weatherData = await _weatherService.getWeather(_lat!, _lon!);
    } catch (e) {
      _weatherData = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    await _getLocation();
  }

  Map<String, dynamic> getCurrentWeather() {
    if (_weatherData.isEmpty) return {};
    final current = _weatherData['current'];
    if (current == null) return {};

    return {
      'temperature': current['temperature_2m']?.toString() ?? '--',
      'humidity': current['relative_humidity_2m']?.toString() ?? '--',
      'wind': current['wind_speed_10m']?.toString() ?? '--',
      'uvIndex': current['uv_index']?.toString() ?? '0.0',
      'precipitation': current['precipitation']?.toString() ?? '0',
      'code': current['weather_code'] ?? 0,
    };
  }

  List<Map<String, dynamic>> getHourlyForecast() {
    if (_weatherData.isEmpty) return [];
    final hourly = _weatherData['hourly'];
    if (hourly == null) return [];

    final times = hourly['time'] as List? ?? [];
    final temps = hourly['temperature_2m'] as List? ?? [];
    final codes = hourly['weather_code'] as List? ?? [];

    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];

    for (int i = 0; i < times.length && result.length < 24; i++) {
      final time = DateTime.tryParse(times[i]);
      if (time != null && time.isAfter(now)) {
        result.add({
          'time': time,
          'temperature': temps[i],
          'code': codes[i],
        });
      }
    }

    return result;
  }

  List<Map<String, dynamic>> getDailyForecast() {
    if (_weatherData.isEmpty) return [];
    final daily = _weatherData['daily'];
    if (daily == null) return [];

    final times = daily['time'] as List? ?? [];
    final maxTemps = daily['temperature_2m_max'] as List? ?? [];
    final minTemps = daily['temperature_2m_min'] as List? ?? [];
    final codes = daily['weather_code'] as List? ?? [];

    final List<Map<String, dynamic>> result = [];

    for (int i = 0; i < times.length; i++) {
      final time = DateTime.tryParse(times[i]);
      if (time != null) {
        result.add({
          'date': time,
          'maxTemp': maxTemps[i],
          'minTemp': minTemps[i],
          'code': codes[i],
        });
      }
    }

    return result;
  }

  Map<String, dynamic> getWeatherInfo(int code) {
    return _weatherService.getWeatherInfo(code);
  }
}
