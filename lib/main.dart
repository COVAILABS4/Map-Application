import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'screens/dashboard_page.dart';
import 'screens/auth/login_page.dart';
import 'utils/shared_prefs.dart';
import 'utils/location_service.dart'; // Add location service to handle permissions

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the userId from SharedPrefs
  String? userId = await SharedPrefs.getUserId();

  // Check for permissions and location settings
  bool locationEnabled = await LocationService.isLocationEnabled();
  bool hasPermissions = await LocationService.hasLocationPermissions();

  if (!locationEnabled) {
    // Redirect user to enable location
    await LocationService.openLocationSettings();
  }

  if (!hasPermissions) {
    // Request location permissions
    await LocationService.requestPermissions();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(userId: userId),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? userId;
  const MyApp({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: userId != null ? DashboardPage() : LoginPage(),
    );
  }
}
