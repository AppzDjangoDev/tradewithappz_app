import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode
import 'package:provider/provider.dart';
import '../theme_notifier.dart'; // Adjust path if needed
import 'home_page.dart'; // Ensure the home_page.dart path is correct
import 'package:shared_preferences/shared_preferences.dart';

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
    final url = 'https://65c7-2401-4900-6472-7006-dd5-104c-63b9-fed2.ngrok-free.app/api/csrf-token/'; // Replace with your actual CSRF endpoint
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

      final url = 'https://65c7-2401-4900-6472-7006-dd5-104c-63b9-fed2.ngrok-free.app/api/login/';
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
              'https://images.unsplash.com/photo-1698847102523-cb8643d755a4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8MTl8fHxlbnwwfHx8fHw%3D',
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
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Background color of button
                          foregroundColor: Colors.white, // Text color
                          minimumSize: Size(double.infinity, 50), // Full width and height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Login'),
                      )
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
