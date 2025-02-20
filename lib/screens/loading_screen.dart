import 'package:flutter/material.dart';
import '../utils/shared_prefs.dart';
import '../utils/location_service.dart';
import 'dashboard_page.dart';
import 'auth/login_page.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _permissionGranted = false;
  bool _permissionDenied = false; // Track permission denial
  String _greeting = "";
  IconData _icon = Icons.wb_sunny; // Default to sunny (day)

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
    _setGreetingAndIcon();
  }

  // Set greeting and icon based on current time
  void _setGreetingAndIcon() {
    final currentTime = DateTime.now();
    final hour = currentTime.hour;

    if (hour >= 5 && hour < 12) {
      _greeting = "Good Morning";
      _icon = Icons.wb_sunny; // Sun icon for morning
    } else if (hour >= 12 && hour < 17) {
      _greeting = "Good Afternoon";
      _icon = Icons.wb_sunny; // Sun icon for afternoon
    } else if (hour >= 17 && hour < 20) {
      _greeting = "Good Evening";
      _icon = Icons.nightlight_round; // Moon icon for evening
    } else {
      _greeting = "Good Night";
      _icon = Icons.nightlight_round; // Moon icon for night
    }

    setState(() {});
  }

  Future<void> _checkPermissionStatus() async {
    bool locationEnabled = await LocationService.isLocationEnabled();
    bool hasPermissions = await LocationService.hasLocationPermissions();

    setState(() {
      _permissionGranted = locationEnabled && hasPermissions;
      _permissionDenied = !hasPermissions;
    });

    if (_permissionGranted) {
      _navigateToNextScreen();
    } else if (_permissionDenied) {
      _showPermissionAlert();
    }
  }

  void _navigateToNextScreen() async {
    String? userId = await SharedPrefs.getUserId();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => userId != null ? DashboardPage() : LoginPage(),
        ),
      );
    }
  }

  Future<void> _requestPermission() async {
    await LocationService.requestPermissions();
    await _checkPermissionStatus(); // Check status again after granting
  }

  void _showPermissionAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text("Please enable location to proceed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _greeting,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Spinning icon that changes based on the time of day
            AnimatedRotation(
              turns: 1.0,
              duration: Duration(seconds: 5), // 5 seconds for full rotation
              child: Icon(
                _icon,
                size: 100,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: Text("GET STARTED"),
            ),
          ],
        ),
      ),
    );
  }
}
