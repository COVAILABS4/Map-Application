import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'screens/dashboard_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/loading_screen.dart'; // Add a loading screen
import 'utils/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        splashColor: Colors.transparent, // Remove splash color globally
        highlightColor: Colors.transparent, // Remove highlight color globally
        focusColor: Colors.transparent, // Remove focus color globally
      ),
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(), // Use a Loading screen first
    );
  }
}
