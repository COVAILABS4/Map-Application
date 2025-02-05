import 'package:flutter/material.dart';
import 'package:map_app/screens/location_pages/body_page.dart';
import '../utils/shared_prefs.dart';
import 'auth/login_page.dart';
import 'location_pages/add_location_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? userName = "";
  String? userEmail = "";
  String? userId = "";
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    String? name = await SharedPrefs.getUserName();
    String? email = await SharedPrefs.getUserEmail();
    String? user_id = await SharedPrefs.getUserId();

    setState(() {
      userName = name ?? "Guest User";
      userEmail = email ?? "guest@example.com";
      userId = user_id ?? "";
      isLoading = false; // Data loaded
    });
  }

  void logout(BuildContext context) async {
    await SharedPrefs.clearUserData();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSidebar(context),
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : BodyPage(userId: userId ?? ""),
    );
  }

  /// 🟢 Sidebar with aligned user info and buttons
  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName!,
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    Text(userEmail!,
                        style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.blueAccent),
            title: Text("Add Location", style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddLocationPage()));
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout",
                style: TextStyle(fontSize: 16, color: Colors.red)),
            onTap: () => logout(context),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
