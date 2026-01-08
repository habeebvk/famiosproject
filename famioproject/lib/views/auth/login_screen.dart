import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:famioproject/services/auth_services.dart';

import 'package:famioproject/views/auth/forgot_screen.dart';
import 'package:famioproject/views/auth/register_screen.dart';

import 'package:famioproject/views/hospital/home/bottom_nav.dart';
import 'package:famioproject/views/grocery/home/bottom_nav.dart';
import 'package:famioproject/views/fooddelivery/home/bottom_nav.dart';
import 'package:famioproject/views/cleaning/cleaninghome_screen.dart';
import 'package:famioproject/views/uber/home/bottom_nav.dart';
import 'package:famioproject/views/user/home/bottom_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> _roles = [
    'Hospital',
    'Grocery',
    'Food Delivery',
    'Cleaning',
    'Uber',
    'Patient',
  ];

  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6D0202), Color(0xFF660111)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 8,
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 80, color: Colors.white),
                        const SizedBox(height: 20),
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // ---------------- ROLE DROPDOWN ----------------
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          dropdownColor: Colors.black87,
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          hint: const Text(
                            "Select Role",
                            style: TextStyle(color: Colors.white70),
                          ),
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedRole = value);
                          },
                          validator: (value) =>
                              value == null ? 'Please select a role' : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---------------- EMAIL ----------------
                        _buildTextField(
                          controller: _emailController,
                          hint: "Email",
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // ---------------- PASSWORD ----------------
                        _buildTextField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Minimum 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---------------- LOGIN BUTTON ----------------
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  final roleFromDB =
                                      await _authService.loginUser(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );

                                  // OPTIONAL: verify selected role vs stored role
                                  if (roleFromDB != _selectedRole) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Selected role does not match account role"),
                                      ),
                                    );
                                    return;
                                  }

                                  _navigateToDashboard(context, roleFromDB);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Login", style: TextStyle(fontSize: 18)),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => SignUpPage()),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- ROLE BASED NAVIGATION ----------------
  void _navigateToDashboard(BuildContext context, String role) {
    Widget destination;

    switch (role) {
      case 'Hospital':
        destination = const HospitalBottomNav();
        break;
      case 'Grocery':
        destination = GroceryBottomnav();
        break;
      case 'Food Delivery':
        destination = const FoodBottomnav();
        break;
      case 'Cleaning':
        destination = const AdminDashboard();
        break;
      case 'Uber':
        destination = const UberBottomNav();
        break;
      case 'Patient':
      default:
        destination = const MainScreen();
    }

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (_) => destination),
    );
  }

  // ---------------- REUSABLE TEXT FIELD ----------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
