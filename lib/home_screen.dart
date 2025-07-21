// Full Flutter AQI app now with:
// - Google Maps view with AQI markers
// - Firebase push notifications for high AQI levels
// - 72-hour dummy forecast based on AQI trend

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AQIHome(),
    );
  }
}

class AQIHome extends StatefulWidget {
  const AQIHome({super.key});

  @override
  State<AQIHome> createState() => _AQIHomeState();
}

class _AQIHomeState extends State<AQIHome> {
  final List<String> cities = ["Delhi", "Mumbai", "Bangalore", "Chennai"];
  String selectedCity = "Delhi";
  int? aqi;
  String message = "";
  String emoji = "🙂";
  List<FlSpot> historyData = [];
  List<double> forecastData = [];
  GoogleMapController? mapController;
  final Map<String, LatLng> cityCoords = {
    "Delhi": LatLng(28.6139, 77.2090),
    "Mumbai": LatLng(19.0760, 72.8777),
    "Bangalore": LatLng(12.9716, 77.5946),
    "Chennai": LatLng(13.0827, 80.2707),
  };

  @override
  void initState() {
    super.initState();
    fetchAQIData();
    FirebaseMessaging.instance.requestPermission();
  }

  Future<void> fetchAQIData() async {
    final response = await http.get(
      Uri.parse(
        'https://api.openaq.org/v2/latest?city=$selectedCity&parameter=pm25',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'];

      if (results.isNotEmpty && results[0]['measurements'].isNotEmpty) {
        final value = results[0]['measurements'][0]['value'].toDouble();

        setState(() {
          aqi = value.toInt();
          updateHealthTip(value);
          generateMockHistory();
          generateMockForecast();
        });

        if (aqi != null && aqi! > 150) {
          FirebaseMessaging.instance.subscribeToTopic('high_aqi');
        }
      }
    }
  }

  void updateHealthTip(double value) {
    if (value <= 50) {
      emoji = "😃";
      message = "Air quality is good. Enjoy your day outside!";
    } else if (value <= 100) {
      emoji = "🙂";
      message = "Moderate air quality. Sensitive groups take care.";
    } else if (value <= 150) {
      emoji = "😷";
      message = "Unhealthy for sensitive groups. Consider mask usage.";
    } else {
      emoji = "🚫";
      message = "Unhealthy air. Avoid outdoor activity.";
    }
  }

  void generateMockHistory() {
    historyData = List.generate(
      7,
      (index) => FlSpot(index.toDouble(), (aqi! - 10 + index * 2).toDouble()),
    );
  }

  void generateMockForecast() {
    forecastData = List.generate(
      3,
      (index) => (aqi! + (index + 1) * 5).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Air Quality Forecast App"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: selectedCity,
                  items: cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCity = value;
                      });
                      fetchAQIData();
                      mapController?.moveCamera(
                        CameraUpdate.newLatLng(cityCoords[value]!),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                if (aqi != null) ...[
                  Text(
                    "AQI: $aqi",
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  Text(emoji, style: const TextStyle(fontSize: 48)),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  "Historical AQI",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: historyData,
                          isCurved: true,
                          barWidth: 3,
                          color: Colors.greenAccent,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Forecast AQI (next 72 hrs)",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  forecastData.map((f) => f.toInt()).join(" → "),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: cityCoords[selectedCity]!,
                zoom: 10,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("aqiMarker"),
                  position: cityCoords[selectedCity]!,
                  infoWindow: InfoWindow(
                    title: "$selectedCity AQI",
                    snippet: aqi?.toString(),
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
