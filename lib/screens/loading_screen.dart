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
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    String? userId = await SharedPrefs.getUserId();

    // Request permissions in the background
    bool locationEnabled = await LocationService.isLocationEnabled();
    bool hasPermissions = await LocationService.hasLocationPermissions();

    if (!locationEnabled) {
      await LocationService.openLocationSettings();
    }

    if (!hasPermissions) {
      await LocationService.requestPermissions();
    }

    // Redirect to appropriate page after permissions
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => userId != null ? DashboardPage() : LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()), // Show loading UI
    );
  }
}
