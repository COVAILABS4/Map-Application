import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_app/services/api_service.dart';
import 'package:map_app/utils/shared_prefs.dart'; // Assuming this is your shared prefs helper class

class AddLocationPage extends StatefulWidget {

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final TextEditingController locationController = TextEditingController();
  late String? userId; // Store userId here
  List<Map<String, dynamic>> geoaxis = []; // Stores location data
  bool isTracking = false; // Flag to check if location tracking is active
  Timer? locationTimer;

  // This method gets the userId asynchronously from SharedPrefs
  Future<void> _getUserId() async {
    userId = await SharedPrefs.getUserId(); // Fetch the userId
    print("User ID: $userId"); // Log the userId to verify it
  }

  @override
  void initState() {
    super.initState();
    _getUserId(); // Call the method to fetch userId when the page is loaded
  }

  @override
  void dispose() {
    locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Start/Stop the location tracking
  void toggleTracking() {
    if (isTracking) {
      locationTimer?.cancel(); // Stop the location tracking
      setState(() {
        isTracking = false;
      });
    } else {
      locationTimer = Timer.periodic(Duration(seconds: 2), (_) {
        _fetchAndStoreLocation();
      });
      setState(() {
        isTracking = true;
      });
    }
  }

  // Function to fetch and store current location
  Future<void> _fetchAndStoreLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Location services are disabled. Please enable them."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Location permission denied. Please grant permission."),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    String timestamp = DateTime.now().toIso8601String(); // Current timestamp

    // Store the location data
    if (mounted) {
      // Ensure the widget is still mounted before calling setState
      setState(() {
        geoaxis.add({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": timestamp,
        });
      });
    }

    print(
        "Location saved: ${position.latitude}, ${position.longitude} at $timestamp"); // For verification
  }

  // Save location to server
  Future<void> saveLocation() async {
    userId =
        await SharedPrefs.getUserId(); // Get userId from shared preferences

    if (geoaxis.isNotEmpty && userId != null && userId!.isNotEmpty) {
      bool isSaved = await ApiService.saveLocation(
          userId!, locationController.text.trim(), geoaxis);

      if (isSaved) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Location Saved Successfully!"),
            backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to Save Location"),
            backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Please enter a location and ensure tracking is active"),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Add Location"), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: "Enter Location",
                prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: isTracking ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isTracking ? "Stop Tracking" : "Start Tracking",
                  style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Save Location", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
