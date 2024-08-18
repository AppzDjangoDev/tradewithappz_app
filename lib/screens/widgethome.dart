


// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:url_launcher/url_launcher.dart';


// class WidgetHome extends StatelessWidget {
//   const WidgetHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
//     final double availableHeight = screenHeight - appBarHeight;

//     final double carouselHeight = availableHeight * 0.178;
//     final double cardHeight = (availableHeight - carouselHeight) / 6.5;
//     final double cardWidth = screenWidth * 0.25; // Normal card width
//     final Color cardColor = const Color.fromARGB(243, 9, 9, 9);

//     return FutureBuilder<Map<String, dynamic>>(
//       future: fetchProfileData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Stack(
//               children: [
//                 Container(
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       image: NetworkImage('https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const Center(
//                   child: SpinKitFadingCircle(
//                     color: Colors.white,
//                     size: 50.0,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return Scaffold(
//             body: Stack(
//               children: [
//                 Container(
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       image: NetworkImage('https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () => _launchUrl('https://spacewear.onrender.com/login'),
//                     child: const Text('FYERS LOGIN'),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         final profileData = snapshot.data;
//         final List<dynamic> fundData = profileData?['fund_limit'] ?? [];

//         // Fetch specific fund limits for the carousels
//         final availableBalance = (fundData.firstWhere((fund) => fund['title'] == 'Available Balance', orElse: () => {'equityAmount': 0})['equityAmount'] as num).toDouble();
//         final opening_balance = (fundData.firstWhere((fund) => fund['title'] == 'Limit at start of the day', orElse: () => {'equityAmount': 0})['equityAmount'] as num).toDouble();
//         final realizedProfitAndLoss = (fundData.firstWhere((fund) => fund['title'] == 'Realized Profit and Loss', orElse: () => {'equityAmount': 0})['equityAmount'] as num).toDouble();

//         final utilizedAmount = (fundData.firstWhere((fund) => fund['title'] == 'Utilized Amount', orElse: () => {'equityAmount': 0})['equityAmount'] as num).toDouble();
//         final fundTransfer = (fundData.firstWhere((fund) => fund['title'] == 'Fund Transfer', orElse: () => {'equityAmount': 0})['equityAmount'] as num).toDouble();
//         final limitAtStartOfDay = (fundData.firstWhere((fund) => fund['title'] == 'Limit at start of the day', orElse: () => {'equityAmount': 0})['equityAmount'] as num).toDouble();

//         final List<Widget> carouselItems = [
//           _buildFirstCarouselItem(availableBalance, realizedProfitAndLoss, cardColor, carouselHeight),
//           _buildSecondCarouselItem(utilizedAmount, fundTransfer, limitAtStartOfDay, cardColor, carouselHeight),
//         ];

//         return Scaffold(
//           body: Stack(
//             children: [
//               Container(
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: NetworkImage('https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               Column(
//                 children: [
//                   const SizedBox(height: 125),
//                   Container(
//                     height: carouselHeight,
//                     child: CarouselSlider(
//                       options: CarouselOptions(
//                         height: carouselHeight,
//                         viewportFraction: 0.95,
//                         enlargeCenterPage: true,
//                         autoPlay: false,
//                         enableInfiniteScroll: false,
//                       ),
//                       items: carouselItems,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: GridView.builder(
//                       padding: const EdgeInsets.all(12.0),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 15.0,
//                         mainAxisSpacing: 15.0,
//                         childAspectRatio: cardWidth / cardHeight,
//                       ),
//                       itemCount: 12,
//                       itemBuilder: (BuildContext context, int index) {
//                         // Adjust width for Profit Status card
//                         if (index == 0) {
//                           return SizedBox(
//                             width: cardWidth * 2, // Double width for Profit Status
//                             height: cardHeight,
//                             child: DashboardCard(index: index, cardColor: cardColor, isWide: true, realizedProfitAndLoss: realizedProfitAndLoss), // Pass realizedProfitAndLoss
//                           );
//                         } else if (index == 1) {
//                           return SizedBox(
//                             width: cardWidth * 2, // Double width for Loss Status
//                             height: cardHeight,
//                             child: DashboardCard(index: index, cardColor: cardColor, isWide: true, realizedProfitAndLoss: realizedProfitAndLoss), // Pass realizedProfitAndLoss
//                           );
//                         } if (index == 2) {
//                           return SizedBox(
//                             width: cardWidth,
//                             height: cardHeight,
//                             child: DashboardCard(index: index, cardColor: cardColor, availableBalance: availableBalance), // Pass availableBalance
//                           );
//                         }else  {
//                           return SizedBox(
//                             width: cardWidth,
//                             height: cardHeight,
//                             child: DashboardCard(index: index, cardColor: cardColor, opening_balance: opening_balance), // Pass availableBalance
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFirstCarouselItem(double availableBalance, double realizedProfitAndLoss, Color color, double carouselHeight) {
//     return Container(
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             right: 8,
//             top: 8,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'Available Balance: $availableBalance',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'Realized Profit and Loss: $realizedProfitAndLoss',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSecondCarouselItem(double utilizedAmount, double fundTransfer, double limitAtStartOfDay, Color color, double carouselHeight) {
//     return Container(
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             right: 8,
//             top: 8,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'Utilized Amount: $utilizedAmount',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'Fund Transfer: $fundTransfer',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'Limit at Start of the Day: $limitAtStartOfDay',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }




//   Future<void> refreshAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final appId = prefs.getString('client_id');
//     final secretKey = prefs.getString('secret_key');
//     final accessToken = prefs.getString('access_token');
//     final pin = '2255'; // Replace with the actual pin

//     if (appId == null || accessToken == null || secretKey == null) {
//       throw Exception('Missing app_id, access_token, or secret_key');
//     }

//     final appIdHash = sha256.convert(utf8.encode('$appId:$secretKey')).toString();

//     final url = Uri.parse('https://api-t1.fyers.in/api/v3/validate-refresh-token');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'grant_type': 'refresh_token',
//         'appIdHash': appIdHash,
//         'refresh_token': accessToken,
//         'pin': pin,
//       }),
//     );

//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as Map<String, dynamic>;
//       final newAccessToken = data['access_token'];
//       prefs.setString('access_token', newAccessToken);
//     } else {
//       throw Exception('Failed to refresh access token');
//     }
//   }

//   Future<Map<String, dynamic>> fetchProfileData() async {
//     await refreshAccessToken();

//     final prefs = await SharedPreferences.getInstance();
//     final appId = prefs.getString('client_id');
//     final accessToken = prefs.getString('access_token');

//     if (appId == null || accessToken == null) {
//       throw Exception('Missing app_id or access_token');
//     }

//     final url = Uri.parse('https://api-t1.fyers.in/api/v3/funds');
//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': '$appId:$accessToken',
//       },
//     );

//     print('Response body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as Map<String, dynamic>;
//       return data; // Return the entire data response
//     } else {
//       throw Exception('Failed to fetch profile data');
//     }
//   }
// }

// class DashboardCard extends StatelessWidget {
//   final int index;
//   final Color cardColor;
//   final bool isWide;
//   final double realizedProfitAndLoss;
//   final double availableBalance;
//   final double opening_balance;

//   const DashboardCard({
//     Key? key,
//     required this.index,
//     required this.cardColor,
//     this.isWide = false,
//     this.realizedProfitAndLoss = 0.0,
//     this.availableBalance = 0.0,
//     this.opening_balance = 0.0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 150.0, // Fixed height for the card
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             top: 8.0,
//             right: 8.0,
//             child: Icon(
//               index == 0
//                   ? realizedProfitAndLoss >= 0 ? Icons.trending_up : Icons.trending_down
//                   : index == 1
//                       ? realizedProfitAndLoss <= 0 ? Icons.trending_down : Icons.trending_up
//                       : index == 2 ? Icons.attach_money
//                       : index == 3 ? Icons.account_balance_wallet
//                       : index == 4 ? Icons.monetization_on
//                       : index == 5 ? Icons.payments
//                       : index == 6 ? Icons.account_balance
//                       : index == 7 ? Icons.notifications
//                       : index == 8 ? Icons.access_time
//                       : index == 9 ? Icons.account_balance
//                       : Icons.info,
//               color: index == 0 || index == 1
//                   ? realizedProfitAndLoss >= 0 ? Colors.green : Colors.red
//                   : index == 2 ? Colors.blue
//                   : index == 3 ? Colors.orange
//                   : index == 4 ? Colors.purple
//                   : index == 5 ? Colors.teal
//                   : index == 6 ? Colors.blueGrey
//                   : index == 7 ? Colors.red
//                   : index == 8 ? Colors.cyan
//                   : index == 9 ? Colors.green
//                   : Colors.grey,
//               size: 24.0, // Smaller icon size
//             ),
//           ),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0), // Adjust vertical padding
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Display the value in the middle
//                   Text(
//                     index == 0 || index == 1 ? '$realizedProfitAndLoss' : index == 2 ? '$availableBalance' : index == 3 ? '$opening_balance' : 'N/A',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 22.0, // Slightly smaller font size for the value
//                     ),
//                   ),
//                   SizedBox(height: 6.0), // Reduced space between value and text
//                   // Display the text at the bottom
//                   Text(
//                     index == 0 ? 'Profit Status' : index == 1 ? 'Loss Status' : index == 2 ? 'Avilable Balance' : index == 3 ? 'Opening Balance' : 'Other Card',
//                     style: const TextStyle(color: Colors.white, fontSize: 14.0), // Font size for text at the bottom
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// Future<void> _launchUrl(String? url) async {
//   if (url == null) {
//     // Handle the case when the URL is null
//     print('URL is null');
//     return;
//   }

//   final Uri uri = Uri.parse(url);
//   if (!await launchUrl(uri)) {
//     throw Exception('Could not launch $url');
//   }
// }