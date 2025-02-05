import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'location_page.dart';

import 'package:intl/intl.dart';

class BodyPage extends StatefulWidget {
  final String userId;
  BodyPage({required this.userId});

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  List<dynamic> locations = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    loadLocations();
  }

  Future<void> loadLocations() async {
    setState(() {
      isLoading = true; // Set loading to true when starting to load data
    });

    List<dynamic>? data = await ApiService.getUserLocations(widget.userId);
    if (data != null) {
      setState(() {
        locations = data;
        isLoading = false; // Set loading to false when data is loaded
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false if no data is returned
      });
    }
  }

  void confirmDelete(String locationId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this location?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                bool success = await ApiService.deleteLocation(locationId);
                if (success) {
                  setState(() {
                    locations.removeWhere((loc) => loc["_id"] == locationId);
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showUpdateDialog(String locationId, String currentName) {
    TextEditingController nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Location"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "New Location Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                bool success = await ApiService.updateLocation(
                    locationId, nameController.text);
                if (success) {
                  setState(() {
                    locations = locations.map((loc) {
                      if (loc["_id"] == locationId) {
                        loc["locationName"] = nameController.text;
                      }
                      return loc;
                    }).toList();
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  String formatDate(String timestamp) {
    // Parse the timestamp string to a DateTime object
    DateTime dateTime = DateTime.parse(timestamp);

    // Use DateFormat to format the DateTime object to the desired format
    String formattedDate = DateFormat('dd/MM/yyyy HH:MM:SS').format(dateTime);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Locations",
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(onPressed: loadLocations, icon: Icon(Icons.restart_alt))
        ],
      ),
      body: isLoading
          ? Center(
              child: Image.asset(
                  'assets/giffs/loader.gif'), // Show GIF while loading
            )
          : locations.isEmpty
              ? Center(child: Text("Location is Empty"))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    var location = locations[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading:
                            Icon(Icons.location_on, color: Colors.blueAccent),
                        title: Text(location["locationName"],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(formatDate(
                            "${location["geoaxis"][0]['timestamp']}")),
                        trailing: Wrap(
                          spacing: 10,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
                              onPressed: () => showUpdateDialog(
                                  location["_id"], location["locationName"]),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(location["_id"]),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationPage(
                                  userId: widget.userId,
                                  locationId: location["_id"]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
