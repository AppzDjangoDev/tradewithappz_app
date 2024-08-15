import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode
import 'package:provider/provider.dart';
import '../theme_notifier.dart'; // Adjust path if needed
import 'home_page.dart'; // Ensure the home_page.dart path is correct

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

  @override
  void initState() {
    super.initState();
    _retrieveCsrfToken(); // Retrieve CSRF token on initialization
  }

  Future<void> _retrieveCsrfToken() async {
    final url = 'https://e7aa-2401-4900-6472-7006-1c41-f227-56c0-af25.ngrok-free.app/api/csrf-token/'; // Replace with your actual CSRF endpoint
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
      final url = 'https://e7aa-2401-4900-6472-7006-1c41-f227-56c0-af25.ngrok-free.app/api/login/';
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            // Comment or remove the CSRF token header if not required
            // if (_csrfToken != null) 'X-CSRFToken': _csrfToken!,
          },
          body: jsonEncode({
            'username': _usernameController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Login successful: $data');
          
          // Store authentication state if needed

          // Navigate to HomePage
          Navigator.of(context).pushReplacementNamed('/home'); // Use named route for better control
        } else {
          // Login failed
          print('Login failed: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter username' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
