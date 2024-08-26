import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart'; // For sha256 hashing
import 'home_page.dart'; // Import the HomePage for navigation

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = fetchProfileData();
  }

  Future<void> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final appId = prefs.getString('client_id');
    final secretKey = prefs.getString('secret_key');
    final accessToken = prefs.getString('access_token');
    final pin = '2255'; // Replace with the actual pin

    if (appId == null || accessToken == null || secretKey == null) {
      throw Exception('Missing app_id, access_token, or secret_key');
    }

    final appIdHash = sha256.convert(utf8.encode('$appId:$secretKey')).toString();

    final url = Uri.parse('https://api-t1.fyers.in/api/v3/validate-refresh-token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'grant_type': 'refresh_token',
        'appIdHash': appIdHash,
        'refresh_token': accessToken,
        'pin': pin,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final newAccessToken = data['access_token'];
      prefs.setString('access_token', newAccessToken);
    } else {
      throw Exception('Failed to refresh access token');
    }
  }

  Future<Map<String, dynamic>> fetchProfileData() async {
    await refreshAccessToken(); // Refresh the access token before fetching profile data

    final prefs = await SharedPreferences.getInstance();
    final appId = prefs.getString('client_id');
    final accessToken = prefs.getString('access_token');

    if (appId == null || accessToken == null) {
      throw Exception('Missing app_id or access_token');
    }

    final url = Uri.parse('https://api-t1.fyers.in/api/v3/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': '$appId:$accessToken',
      },
    );
    print('Response profile: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to fetch profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww'), // Replace with your background image URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Profile content
          FutureBuilder<Map<String, dynamic>>(
            future: _profileData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No profile data found.'));
              }

              final profileData = snapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 125),
                      Center(
                        child: Card(
                          color: Color.fromARGB(243, 9, 9, 9), // Background color of the card
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 5,
                          child: Container(
                            width: double.infinity,
                            height: 270, // Increased height
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 70, // Increased size
                                  backgroundImage: NetworkImage(profileData['image'] ?? 'https://via.placeholder.com/150'),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  profileData['name'] ?? 'Name not available',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  profileData['email_id'] ?? 'Email not available',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildProfileDetailCard(
                        context,
                        'Mobile Number: ${profileData['mobile_number'] ?? 'Not available'}',
                        Icons.phone,
                      ),
                      SizedBox(height: 8),
                      _buildProfileDetailCard(
                        context,
                        'FY ID: ${profileData['fy_id'] ?? 'Not available'}',
                        Icons.credit_card,
                      ),
                      SizedBox(height: 8),
                      _buildProfileDetailCard(
                        context,
                        'PIN Change Date: ${profileData['pin_change_date'] ?? 'Not available'}',
                        Icons.pin,
                      ),
                      SizedBox(height: 8),
                      _buildProfileDetailCard(
                        context,
                        'Password Change Date: ${profileData['pwd_change_date'] ?? 'Not available'}',
                        Icons.lock,
                      ),
                      SizedBox(height: 8),
                      _buildProfileDetailCard(
                        context,
                        'PAN: ${profileData['PAN'] ?? 'Not available'}',
                        Icons.credit_card,
                      ),
                      SizedBox(height:80),
                      _buildBackButton(context),
                      SizedBox(height:50),
                    ],
                  ),
                ),
              );
            },
          ),
          // Floating Action Buttons
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
            top: 60,
            left: 80,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "My Account",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailCard(BuildContext context, String text, IconData icon) {
    return Card(
      color: Color.fromARGB(243, 9, 9, 9), // Background color of the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 8,
      child: SizedBox(
        width: double.infinity, // Full width
        height: 65, // Fixed height
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: const Color.fromARGB(255, 107, 107, 107)),
              SizedBox(width: 50),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      child: Card(
        color: Color.fromARGB(243, 9, 9, 9), // Background color of the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 10,
        child: SizedBox(
          width: double.infinity, // Full width
          height: 65, // Fixed height
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center, // Center align the text
                    child: Text(
                      'Back to Home',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, // Make text bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
