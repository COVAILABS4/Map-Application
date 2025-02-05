import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'location_page.dart';

class BodyPage extends StatefulWidget {
  final String userId;
  BodyPage({required this.userId});

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  List<dynamic> locations = [];

  @override
  void initState() {
    super.initState();
    loadLocations();
  }

  Future<void> loadLocations() async {
    print("hello World  ${widget.userId}");

    List<dynamic>? data = await ApiService.getUserLocations(widget.userId);
    if (data != null) {
      setState(() {
        locations = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Locations",
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(onPressed: loadLocations, icon: Icon(Icons.restart_alt))
        ],
      ),
      body: locations.isEmpty
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
                    leading: Icon(Icons.location_on, color: Colors.blueAccent),
                    title: Text(location["locationName"],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text("ID: ${location["_id"]}"),
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
