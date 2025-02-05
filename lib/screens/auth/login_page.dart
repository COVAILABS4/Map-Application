import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../dashboard_page.dart';
import 'register_page.dart';
import '../../services/api_service.dart';
import '../../utils/shared_prefs.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;

  void login() async {
    setState(() => isLoading = true);

    final response = await ApiService.loginUser(
      emailController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (response != null) {
      String userId = response['user']['_id'];
      String email = response['user']['email_id'];
      String name = response['user']['name'];

      Provider.of<UserProvider>(context, listen: false)
          .setUserData(userId, email, name);

      await SharedPrefs.saveUserId(userId);
      await SharedPrefs.saveUserEmail(email);
      await SharedPrefs.saveUserName(name);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Login Successful!"), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Login Failed! Check credentials."),
            backgroundColor: Colors.red),
      );
    }
  }

  // void login() async {
  //   setState(() => isLoading = true);

  //   final response = await ApiService.loginUser(
  //     emailController.text,
  //     passwordController.text,
  //   );

  //   setState(() => isLoading = false);

  //   if (response != null) {
  //     String userId = response['user']['_id'];
  //     Provider.of<UserProvider>(context, listen: false).setUserId(userId);
  //     await SharedPrefs.saveUserId(userId);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text("Login Successful!"), backgroundColor: Colors.green),
  //     );

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => DashboardPage()),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text("Login Failed! Check credentials."),
  //           backgroundColor: Colors.red),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Login",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.blueAccent),
              SizedBox(height: 20),

              // Email Field
              _buildTextField(
                  emailController, "Email Address", Icons.email, false,
                  keyboardType: TextInputType.emailAddress),

              // Password Field with Visibility Toggle
              _buildPasswordField(
                  passwordController, "Password", isPasswordVisible, () {
                setState(() => isPasswordVisible = !isPasswordVisible);
              }),

              SizedBox(height: 20),

              // Login Button
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: Text("Login"),
                    ),

              SizedBox(height: 20),

              // Register Button
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RegisterPage()));
                },
                child: Text("Don't have an account? Register",
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generic Input Field
  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool obscureText,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // Password Input Field with Toggle Visibility
  Widget _buildPasswordField(TextEditingController controller, String label,
      bool isVisible, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey),
            onPressed: toggleVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
