import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart'; // Add this import for SHA-256

class WidgetHome extends StatelessWidget {
  const WidgetHome({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    final double availableHeight = screenHeight - appBarHeight;

    final double carouselHeight = availableHeight * 0.178;
    final double cardHeight = (availableHeight - carouselHeight) / 6; // Adjusted to increase space between cards

    final double cardWidth = screenWidth * 0.25; // Reduced width to make cards smaller

    final Color cardColor = Color.fromARGB(243, 9, 9, 9); // Define the color for consistency

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchProfileData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error fetching profile data')),
          );
        }

        final profileData = snapshot.data;
        final List<Widget> carouselItems = [
          _buildCarouselItem('Name: ${profileData?['name'] ?? 'N/A'}', cardColor),
          _buildCarouselItem('Email: ${profileData?['email_id'] ?? 'N/A'}', cardColor),
          _buildCarouselItem('PAN: ${profileData?['PAN'] ?? 'N/A'}', cardColor),
        ];

        return Scaffold(
          body: Stack(
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Foreground content
              Column(
                children: [
                  Container(
                    height: carouselHeight,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: carouselHeight,
                        viewportFraction: 0.95,
                        enlargeCenterPage: true,
                        autoPlay: false,
                        enableInfiniteScroll: false,
                      ),
                      items: carouselItems,
                    ),
                  ),
                  const SizedBox(height: 10), // Increased space between carousel and grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12.0), // Increased padding
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Changed to 3 columns
                        crossAxisSpacing: 15.0, // Increased spacing between cards
                        mainAxisSpacing: 15.0, // Increased spacing between rows
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemCount: 12,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: DashboardCard(index: index, cardColor: cardColor),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color, // Use the same color for the carousel items
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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

    // Print the incoming response as a string
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

    final url = Uri.parse('https://api-t1.fyers.in/api/v3/funds');
    final response = await http.get(
      url,
      headers: {
        'Authorization': '$appId:$accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to fetch profile data');
    }
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.index, required this.cardColor});

  final int index;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Profit Status',
      'Loss Status',
      'Revenue',
      'Expenses',
      'Investments',
      'Savings',
      'Growth',
      'Targets',
      'Projects',
      'Goals',
      'Achievements',
      'Insights',
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.transparent, // Set the card color to transparent
      child: Container(
        decoration: BoxDecoration(
          color: cardColor, // Use the same color for the cards
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.bar_chart,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                titles[index],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Details here',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
