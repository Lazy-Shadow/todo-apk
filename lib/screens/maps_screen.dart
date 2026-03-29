import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/weather_provider.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => MapsScreenState();
}

class MapsScreenState extends State<MapsScreen> {
  final TextEditingController _searchController = TextEditingController();
  WebViewController? _webViewController;
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
      _initGoogleMaps();
    }
  }

  String _buildGoogleMapsUrl(String query) {
    final encodedQuery = Uri.encodeComponent(query);
    const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    return 'https://www.google.com/maps/embed/v1/place?key=$apiKey&q=$encodedQuery&zoom=15';
  }

  void _initGoogleMaps() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      );
    if (_currentLocation != null) {
      _loadGoogleMaps('${_currentLocation!.latitude},${_currentLocation!.longitude}');
    }
  }

  void _loadGoogleMaps(String query) {
    if (_webViewController != null) {
      final url = _buildGoogleMapsUrl(query);
      _webViewController!.loadRequest(Uri.parse(url));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    await weather.refreshLocation();
    if (weather.lat != null && weather.lon != null) {
      setState(() {
        _currentLocation = LatLng(weather.lat!, weather.lon!);
      });
      if (_webViewController != null) {
        _loadGoogleMaps('${_currentLocation!.latitude},${_currentLocation!.longitude}');
      }
    }
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
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _loadGoogleMaps(value);
                    }
                  },
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
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Detecting your location...',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : _webViewController == null
                  ? const Center(child: CircularProgressIndicator())
                  : WebViewWidget(controller: _webViewController!),
        ),
      ],
    );
  }
}
