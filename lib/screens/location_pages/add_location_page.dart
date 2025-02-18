import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_app/screens/location_pages/geo_show.dart';
import 'package:map_app/utils/shared_prefs.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final TextEditingController locationController = TextEditingController();
  String? userId; // Store userId here
  List<Map<String, dynamic>> geoaxis = [];
  bool isTracking = false;
  Timer? locationTimer;

  // This method gets the userId asynchronously from SharedPrefs
  Future<void> _getUserId() async {
    String? fetchUid = await SharedPrefs.getUserId(); // Fetch the u  serId

    setState(() {
      userId = fetchUid;
    });
    print("User ID: $userId"); // Log the userId to verify it
  }

  @override
  void initState() {
    super.initState();
    _getUserId(); // Fetch userId when the page initializes
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  void toggleTracking() {
    if (isTracking) {
      locationTimer?.cancel();
      setState(() => isTracking = false);
    } else {
      locationTimer = Timer.periodic(Duration(seconds: 2), (_) {
        _fetchAndStoreLocation();
      });
      setState(() => isTracking = true);
    }
  }

  Future<void> _fetchAndStoreLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage("Location services are disabled.", Colors.red);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage("Location permission denied.", Colors.red);
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String timestamp = DateTime.now().toIso8601String();

    if (mounted) {
      setState(() {
        geoaxis.add({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": timestamp,
          "name": locationController.text.trim(),
        });
      });
    }
  }

  Future<void> saveLocation() async {
    if (userId == null) {
      _showMessage("User ID not found. Please try again.", Colors.red);
      return;
    }

    if (locationController.text.trim().isEmpty) {
      _showMessage("Please enter a location name before saving.", Colors.red);
      return;
    }

    if (geoaxis.isNotEmpty) {
      bool isSaved = await ApiService.saveLocation(
          userId!, locationController.text.trim(), geoaxis);
      _showMessage(
          isSaved ? "Location Saved Successfully!" : "Failed to Save Location",
          isSaved ? Colors.green : Colors.red);
      if (isSaved) {
        setState(() {
          geoaxis.clear();
          locationController.clear();
        });
      }
    } else {
      _showMessage(
          "Please ensure tracking is active before saving.", Colors.red);
    }
  }

  void clearLocations() {
    setState(() {
      geoaxis.clear();
      locationController.clear();
    });
    _showMessage("Location data cleared.", Colors.blue);
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
            Expanded(
              child: GeoShow(geoaxis: geoaxis),
            ),
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
            Text("Location Count: ${geoaxis.length}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isTracking ? null : toggleTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Start"),
                ),
                ElevatedButton(
                  onPressed: isTracking ? toggleTracking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Stop"),
                ),
                ElevatedButton(
                  onPressed: isTracking ? null : saveLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Save"),
                ),
                ElevatedButton(
                  onPressed: clearLocations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Clear"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
