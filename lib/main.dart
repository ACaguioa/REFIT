import 'package:flutter/material.dart';
import 'package:refit/services/sensor_service.dart';
import 'package:refit/services/ai_service.dart';

void main() {
  runApp(const RefitApp());
}

class RefitApp extends StatelessWidget {
  const RefitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REFIT IoT Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.green,
      ),
      home: const RefitHomeScreen(),
    );
  }
}

class RefitHomeScreen extends StatefulWidget {
  const RefitHomeScreen({super.key});

  @override
  State<RefitHomeScreen> createState() => _RefitHomeScreenState();
}

class _RefitHomeScreenState extends State<RefitHomeScreen> with SingleTickerProviderStateMixin {
  final SensorService _sensorService = SensorService();
  late AnimationController _animController;
  late Animation<double> _animation;

  SensorData? _sensorData;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _stateTemplates = [
    {
      "statusTitle": "FILTER STATUS\nNORMAL",
      "statusSub": "Your filter is working well. Low carbon emission.",
      "color": Colors.green,
      "buttonText": "View Details",
    },
    {
      "statusTitle": "FILTER ATTENTION!",
      "statusSub": "The filter requires cleaning! Nangangailangan ng paglilinis!",
      "color": Colors.orange,
      "buttonText": "Check Filter",
    },
    {
      "statusTitle": "FILTER CLEANING\nREQUIRED!",
      "statusSub": "The filter must be cleaned! Dapat linisin ang filter!",
      "color": Colors.red,
      "buttonText": "Open Cleaning Guide",
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    SensorData data = await _sensorService.fetchCurrentSensorState();
    setState(() {
      _sensorData = data;
      _isLoading = false;
    });
    _animController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _sensorData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final template = _stateTemplates[_sensorData!.stateIndex];
    final Color stateColor = template["color"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('REFIT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E1E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF121212)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(backgroundColor: Colors.green, child: 
                  Icon(Icons.local_shipping, color: Colors.white)),
                  SizedBox(height: 10),
                  Text("REFIT Tricycle Monitor", 
                  style: TextStyle(color: Colors.white, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold)),
                  Text("v1.0.0 IoT Edition", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white70),
              title: const Text("Inspection History"),
              subtitle: Text("Last checked: ${_sensorData!.lastChecked}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                _showHistoryDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.eco, color: Colors.green),
              title: const Text("Carbon Reduction Guide"),
              onTap: () {
                Navigator.pop(context);
                _showGuideDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.psychology, color: Colors.blueAccent),
              title: const Text("AI Eco-Consultant"),
              subtitle: const Text("Ask AI about filter lifespan", style: TextStyle(fontSize: 10, color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                _showAiConsultantDialog(context);
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.orange),
              title: const Text("Developer Sensor Switch"),
              subtitle: const Text("Test different pipe states", style: TextStyle(fontSize: 10, color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                _showDevSensorPicker(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Live Status Indicator Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sensors, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text("Last Checked: ${_sensorData!.lastChecked}", style: const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status Alert Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: stateColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: stateColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    _sensorData!.stateIndex == 0 ? Icons.check_circle : (_sensorData!.stateIndex == 1 ? Icons.warning_amber_rounded : Icons.error_outline),
                    color: stateColor,
                    size: 36,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(template["statusTitle"], style: TextStyle(color: stateColor, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(template["statusSub"], style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Animated Circular Gauge Indicator
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double animatedValue = (_sensorData!.percentage / 100) * _animation.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: animatedValue,
                        strokeWidth: 14,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(stateColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(_sensorData!.percentage * _animation.value).toInt()}%",
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text("Filter Condition", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 35),

            // Telemetry Details Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.thermostat, color: Colors.white70),
                    title: const Text("Exhaust Temperature"),
                    trailing: Text(_sensorData!.temperature, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  ),
                  const Divider(color: Colors.grey, height: 1),
                  ListTile(
                    leading: const Icon(Icons.air, color: Colors.white70),
                    title: const Text("Airflow Status"),
                    trailing: Text(_sensorData!.airflow, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: stateColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: stateColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  if (_sensorData!.stateIndex == 2) {
                    _showGuideDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pipe diagnostics optimal. Keep riding green!")),
                    );
                  }
                },
                child: Text(template["buttonText"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("🌿 Carbon & Pipe Cleaning Guide", style: TextStyle(color: Colors.greenAccent)),
        content: const SingleChildScrollView(
          child: Text(
            "To reduce carbon emissions and maintain your reusable tricycle filter:\n\n"
            "1. Remove the filter housing once cool (~180°C operating temp).\n"
            "2. Soak the metallic mesh insert in a degreaser solution for 15 minutes.\n"
            "3. Flush accumulated soot and carbon buildup with clean water.\n"
            "4. Dry completely before reinstalling to ensure smooth airflow and prevent smoke pollution.",
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Got it", style: TextStyle(color: Colors.green))),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("📜 Inspection History", style: TextStyle(color: Colors.white)),
        content: Text("Last Saved Inspection:\n• Timestamp: ${_sensorData?.lastChecked}\n• Condition State: Index ${_sensorData?.stateIndex}\n• Status: ${_sensorData?.airflow}", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  void _showAiConsultantDialog(BuildContext context) async {
    // Show a loading dialog while the AI analyzes the live sensor data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(width: 20),
            Text("REFIT AI analyzing exhaust telemetry...", style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );

    // Fetch live AI advice using the AiService
    String aiResponse = await AiService.getEcoAiAdvice(
      _sensorData!.percentage,
      _sensorData!.temperature,
      _sensorData!.airflow,
    );

    // Close loading dialog
    Navigator.pop(context);

    // Display AI output
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text("REFIT AI Eco-Consultant", style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            aiResponse,
            style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Close", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  void _showDevSensorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("🔧 Developer Sensor Switch", style: TextStyle(color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Simulate sensor output changes for your client test demo:", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                await _sensorService.saveNewSensorReading(0);
                Navigator.pop(context);
                _loadData();
              },
              child: const Text("Set State: NORMAL (Green)"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                await _sensorService.saveNewSensorReading(1);
                Navigator.pop(context);
                _loadData();
              },
              child: const Text("Set State: WARNING (Orange)"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _sensorService.saveNewSensorReading(2);
                Navigator.pop(context);
                _loadData();
              },
              child: const Text("Set State: CLEANING REQUIRED (Red)"),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF1E1E1E), title: const Text("App Settings")),
      body: ListView(
        children: [
          const SwitchListTile(
            title: Text("Push Notifications"),
            subtitle: Text("Alert when pipe needs immediate cleaning"),
            value: true,
            onChanged: null,
          ),
          const SwitchListTile(
            title: Text("Auto-sync IoT Cloud Data"),
            subtitle: Text("Connect via Wi-Fi/ESP32 background service"),
            value: true,
            onChanged: null,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white70),
            title: const Text("About REFIT Project"),
            subtitle: const Text("Reusable filter monitoring system for sustainable transport."),
          ),
        ],
      ),
    );
  }
}