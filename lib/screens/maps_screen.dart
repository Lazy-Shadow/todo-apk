import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    await weather.init();
    if (weather.lat != null && weather.lon != null) {
      setState(() {
        _currentLocation = LatLng(weather.lat!, weather.lon!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a city, street, or landmark...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('My Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _currentLocation == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Detecting your location...',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation!,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.todoapp.todo_apk',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation!,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _getCurrentLocation() async {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    await weather.refreshLocation();
    if (weather.lat != null && weather.lon != null) {
      setState(() {
        _currentLocation = LatLng(weather.lat!, weather.lon!);
      });
      _mapController.move(_currentLocation!, 13);
    }
  }
}
