import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Passwords do not match!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.registerUser(
      nameController.text,
      phoneController.text,
      emailController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Registration Successful!"),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Registration Failed!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Register",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Name Field
              _buildTextField(nameController, "Full Name", Icons.person, false),

              // Phone Field
              _buildTextField(
                  phoneController, "Phone Number", Icons.phone, false,
                  keyboardType: TextInputType.phone),

              // Email Field
              _buildTextField(
                  emailController, "Email Address", Icons.email, false,
                  keyboardType: TextInputType.emailAddress),

              // Password Field with Visibility Toggle
              _buildPasswordField(
                  passwordController, "Password", isPasswordVisible, () {
                setState(() => isPasswordVisible = !isPasswordVisible);
              }),

              // Confirm Password Field with Visibility Toggle
              _buildPasswordField(confirmPasswordController, "Confirm Password",
                  isConfirmPasswordVisible, () {
                setState(
                    () => isConfirmPasswordVisible = !isConfirmPasswordVisible);
              }),

              const SizedBox(height: 20),

              // Register Button
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: register,
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
                      child: Text("Register"),
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
