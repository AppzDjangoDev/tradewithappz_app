import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the HomePage
import 'package:shared_preferences/shared_preferences.dart';

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  _ControlsPageState createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  final Map<String, double> _prefsValues = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys(); // Get all keys from SharedPreferences
    final newPrefsValues = <String, double>{};

    for (String key in keys) {
      final value = prefs.get(key); // Fetch the value for each key
      if (value is double) {
        newPrefsValues[key] = value; // Handle double values
      } else if (value is String) {
        final doubleValue = double.tryParse(value);
        if (doubleValue != null) {
          newPrefsValues[key] = doubleValue; // Handle string values that can be parsed to double
        }
      }
      // Optionally handle other types if needed, e.g., int or bool
    }

    setState(() {
      _prefsValues.clear();
      _prefsValues.addAll(newPrefsValues); // Update _prefsValues with all preferences
    });

    // Print the loaded preferences
    print('Loaded preferences:');
    newPrefsValues.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
  }

  Future<void> _savePreference(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 16,
            child: FloatingActionButton(
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Opens the drawer if present
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.menu, color: Colors.white),
            ),
          ),
          Positioned(
            top: 60,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.home, color: Colors.white),
            ),
          ),
          Positioned(
            top: 120,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _prefsValues.entries.map((entry) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    Slider(
                      value: entry.value,
                      min: 0.0,
                      max: 100.0,
                      onChanged: (value) {
                        setState(() {
                          _prefsValues[entry.key] = value;
                        });
                        _savePreference(entry.key, value);
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Perform logout action
          await _logout(context);
        },
        child: const Icon(Icons.logout),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Implement logout functionality here
    Navigator.pushReplacementNamed(context, '/login');
  }
}
