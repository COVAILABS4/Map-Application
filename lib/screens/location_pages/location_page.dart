import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/services/api_service.dart';
import 'package:map_launcher/map_launcher.dart';

class LocationPage extends StatefulWidget {
  final String userId;
  final String locationId;

  LocationPage({required this.userId, required this.locationId});

  @override
  _UpdateLocationPageState createState() => _UpdateLocationPageState();
}

class _UpdateLocationPageState extends State<LocationPage> {
  Map<String, dynamic>? locationData;

  @override
  void initState() {
    super.initState();
    fetchLocationDetails();
  }

  Future<void> fetchLocationDetails() async {
    print(
        'Fetching location details for locationId: ${widget.locationId} and userId: ${widget.userId}');

    // Make actual API call
    final data =
        await ApiService.getGeoLocation(widget.locationId, widget.userId);

    // Print the raw data response
    print('Raw Data: $data');

    if (data != null && data['location'] != null) {
      print('Location data found: ${data['location']}');
      print('Location Name: ${data['location']['locationName']}');

      setState(() {
        locationData = data['location'];
      });

      print("Successfully retrieved");
    } else {
      print('Location data is null or missing');
      setState(() {
        locationData = null;
      });
    }
  }

  void openMapsSheet(BuildContext context, List<Coords> pathPoints) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      final googleMap = availableMaps.firstWhere(
        (map) => map.mapType == MapType.google,
      );

      await googleMap.showDirections(
        destination: pathPoints.last,
        origin: pathPoints.first,
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (locationData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String name = locationData!['locationName'];
    final List geoaxis = locationData!['geoaxis'];

    final String startTime =
        geoaxis.first['timestamp'].toString().split(" ").last;
    final String endTime = geoaxis.last['timestamp'].toString().split(" ").last;
    final String date = geoaxis.first['timestamp'].toString().split(" ").first;

    final List<Coords> pathPoints = geoaxis
        .map((point) => Coords(point['latitude'], point['longitude']))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Update Location")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Name: $name \n Start Time: $startTime End Time: $endTime \n Date: $date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                        pathPoints.first.latitude, pathPoints.first.longitude),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: pathPoints
                              .map((coord) =>
                                  LatLng(coord.latitude, coord.longitude))
                              .toList(),
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(pathPoints.first.latitude,
                              pathPoints.first.longitude),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                        Marker(
                          point: LatLng(pathPoints.last.latitude,
                              pathPoints.last.longitude),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openMapsSheet(context, pathPoints),
        child: Icon(Icons.directions),
      ),
    );
  }
}
