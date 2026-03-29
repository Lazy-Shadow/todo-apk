import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weather, _) {
        if (weather.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final current = weather.getCurrentWeather();
        final info = weather.getWeatherInfo(current['code'] as int? ?? 0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weather Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getIconData(info['icon'] as String? ?? 'sunny'),
                            size: 80,
                            color: Color(info['color'] as int? ?? 0xFFFFC107),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${current['temperature'] ?? '--'}°C',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                info['desc'] as String? ?? 'Loading...',
                                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.purple.shade300),
                          const SizedBox(width: 4),
                          Text(weather.locationName, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Weather Details Grid
              Row(
                children: [
                  Expanded(child: _WeatherDetail(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${current['humidity'] ?? '--'}%',
                    color: Colors.blue,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _WeatherDetail(
                    icon: Icons.air,
                    label: 'Wind',
                    value: '${current['wind'] ?? '--'} km/h',
                    color: Colors.orange,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _WeatherDetail(
                    icon: Icons.wb_sunny,
                    label: 'UV Index',
                    value: '${current['uvIndex'] ?? '0.0'}',
                    color: Colors.amber,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _WeatherDetail(
                    icon: Icons.grain,
                    label: 'Precipitation',
                    value: '${current['precipitation'] ?? '0'}%',
                    color: Colors.teal,
                  )),
                ],
              ),
              const SizedBox(height: 24),
              // Hourly Forecast
              const Text('Hourly Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weather.getHourlyForecast().length,
                  itemBuilder: (context, index) {
                    final hourly = weather.getHourlyForecast()[index];
                    return Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(hourly['time'] as DateTime).hour}:00',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            _getIconData(hourly['icon'] as String? ?? 'sunny'),
                            size: 24,
                            color: Color(hourly['color'] as int? ?? 0xFFFFC107),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${hourly['temperature'] ?? '--'}°',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // 7-Day Forecast
              const Text('7-Day Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...weather.getDailyForecast().map((daily) {
                final dayInfo = weather.getWeatherInfo(daily['code'] as int? ?? 0);
                final date = daily['date'] as DateTime;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      _getIconData(dayInfo['icon'] as String? ?? 'sunny'),
                      color: Color(dayInfo['color'] as int? ?? 0xFFFFC107),
                    ),
                    title: Text(
                      date.day == DateTime.now().day ? 'Today' : _getDayName(date.weekday),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${daily['minTemp']?.round() ?? '--'}°',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const Text(' / '),
                        Text(
                          '${daily['maxTemp']?.round() ?? '--'}°',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'partly_cloudy_day':
        return Icons.cloud;
      case 'foggy':
        return Icons.foggy;
      case 'rainy':
        return Icons.water_drop;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'shower':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'cloud':
      default:
        return Icons.cloud;
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
