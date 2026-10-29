import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SensorData {
  final int percentage;
  final String temperature;
  final String airflow;
  final int stateIndex; // 0: Normal, 1: Warning, 2: Cleaning Required
  final String lastChecked;

  SensorData({
    required this.percentage,
    required this.temperature,
    required this.airflow,
    required this.stateIndex,
    required this.lastChecked,
  });
}

class SensorService {
  // Simulating sensor reads. Developers can easily swap this out with actual ESP32 HTTP/MQTT/Firebase calls later!
  Future<SensorData> fetchCurrentSensorState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Simulating current read (For demonstration, defaulting to State 1: Warning)
    int stateIndex = prefs.getInt('last_state_index') ?? 1; 
    int percentage = stateIndex == 0 ? 72 : (stateIndex == 1 ? 82 : 100);
    String temp = stateIndex == 0 ? "185°C" : (stateIndex == 1 ? "195°C" : "210°C");
    String airflow = stateIndex == 0 ? "Normal" : (stateIndex == 1 ? "Slightly Reduced" : "Reduced");
    
    String now = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} - ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}";
    String lastChecked = prefs.getString('last_checked_time') ?? now;

    // Save history
    await prefs.setString('last_checked_time', lastChecked);
    await prefs.setInt('last_state_index', stateIndex);

    return SensorData(
      percentage: percentage,
      temperature: temp,
      airflow: airflow,
      stateIndex: stateIndex,
      lastChecked: lastChecked,
    );
  }

  // Method for developers/clients to update sensor states programmatically when wiring real hardware
  Future<void> saveNewSensorReading(int newStateIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_state_index', newStateIndex);
    String now = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} - ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}";
    await prefs.setString('last_checked_time', now);
  }
}