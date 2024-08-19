import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import the spinkit package

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _csrfToken; // Variable to store CSRF token
  bool _isLoading = false; // Variable to show loading state

  @override
  void initState() {
    super.initState();
    _retrieveCsrfToken(); // Retrieve CSRF token on initialization
  }

  Future<void> _retrieveCsrfToken() async {
    final url = 'https://3a4a-2401-4900-6671-6213-c9fa-ec22-8bdf-8492.ngrok-free.app/api/csrf-token/'; // Replace with your actual CSRF endpoint
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _csrfToken = data['csrf_token']; // Adjust based on your backend's response
        });
        print('CSRF Token retrieved successfully: $_csrfToken'); // Debug line
      } else {
        throw Exception('Failed to retrieve CSRF token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error retrieving CSRF token: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving CSRF token. Please try again later.')),
      );
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading animation
      });

      final url = 'https://3a4a-2401-4900-6671-6213-c9fa-ec22-8bdf-8492.ngrok-free.app/api/login/';
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': _csrfToken ?? '', // Include CSRF token
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'username': _usernameController.text,
            'password': _passwordController.text,
          }),
        );

        setState(() {
          _isLoading = false; // Hide loading animation
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Login successful: $data');

          // Store authentication state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['access_token']);
          await prefs.setString('client_id', data['client_id']);
          await prefs.setString('secret_key', data['secret_key']);
          await prefs.setString('timestamp', data['timestamp']);
          await prefs.setString('date', data['date']);
          await prefs.setString('auth_code_url', data['auth_code_url']); // Store auth_code_url in session

          // Navigate to HomePage
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Login failed
          print('Login failed: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Hide loading animation
        });
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during login. Please try again.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay to make form readable
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Centered login form
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.87, // Reduce width to 80% of screen width
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 28, 26, 26)!, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 28, 26, 26)!, width: 1.5),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16), // Add padding inside the field
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Enter username' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.87, // Reduce width to 80% of screen width
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 28, 26, 26)!, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 28, 26, 26)!, width: 1.5),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16), // Add padding inside the field
                          ),
                          style: TextStyle(color: Colors.white),
                          obscureText: true,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Enter password' : null,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85, // Reduce width to 80% of screen width
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(147, 89, 89, 89)!, // Background color of button
                            foregroundColor: Colors.white, // Text color
                            minimumSize: Size(double.infinity, 50), // Full width and height
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SpinKitWave(
                                  color: Colors.white,
                                  size: 25.0,
                                )
                              : const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
