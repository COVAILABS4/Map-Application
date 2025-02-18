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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    String? userId = await SharedPrefs.getUserId();

    // Check location permission
    bool locationEnabled = await LocationService.isLocationEnabled();
    bool hasPermissions = await LocationService.hasLocationPermissions();

    if (!locationEnabled || !hasPermissions) {
      bool granted = await _requestLocationPermission();
      if (!granted) {
        setState(() {
          _isLoading = false; // Stop loader and show error message
        });
        return;
      }
    }

    // Navigate to the next screen only if permissions are granted
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => userId != null ? DashboardPage() : LoginPage(),
        ),
      );
    }
  }

  // Function to request location permission with UI interaction
  Future<bool> _requestLocationPermission() async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing without action
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text(
            "This app requires location permission to continue. Please enable it.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await LocationService.requestPermissions();
                bool hasPermissions =
                    await LocationService.hasLocationPermissions();
                Navigator.of(context).pop(hasPermissions);
              },
              child: Text("Grant Permission"),
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
        child: _isLoading
            ? CircularProgressIndicator()
            : Text("Permission denied. Please enable location to proceed."),
      ),
    );
  }
}
