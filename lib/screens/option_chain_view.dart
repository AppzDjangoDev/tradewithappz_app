// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:flutter/foundation.dart'; // For debugging purposes
// import 'package:web_socket_channel/web_socket_channel.dart'; // For WebSocket communication
// import 'package:shared_preferences/shared_preferences.dart'; // For shared preferences
// import 'dart:convert';
// import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import the spinkit package


// class OptionChainView extends StatefulWidget {
//   final List<CardInfo> cardInfos;
//   final double carouselHeight;
//   final double listTileHeight;
//   final double carouselWidth;
//   final String webSocketUrl;

//   const OptionChainView({
//     super.key,
//     required this.cardInfos,
//     required this.carouselHeight,
//     required this.listTileHeight,
//     required this.carouselWidth,
//     required this.webSocketUrl,
//   });

//   @override
//   _OptionChainViewState createState() => _OptionChainViewState();
// }

// class _OptionChainViewState extends State<OptionChainView> {
//   List<Map<String, dynamic>> _top5CESymbols = [];
//   List<Map<String, dynamic>> _top5PESymbols = [];
//   WebSocketChannel? _channel; // Make _channel nullable
//   late SharedPreferences _prefs;
//   bool _isLoading = true;
//   late String _currentWsUrl;
//   Map<String, Map<String, dynamic>> _indexSymbol = {}; // Ensure this is not final

//   @override
//   void initState() {
//     super.initState();
//     _initializeSharedPreferences();
//   }

//   Future<void> _initializeSharedPreferences() async {
//     _prefs = await SharedPreferences.getInstance();
//     _webSocketManager();
//   }

//   void _webSocketManager() {
//     _currentWsUrl = widget.webSocketUrl;

//     String? storedUrl = _prefs.getString('webSocketUrl');
    
//     if (storedUrl == null || storedUrl != _currentWsUrl) {
//       // URL is either null or has changed
//       if (storedUrl != null) {
//         _endCurrentWebSocket(); // Close existing connection
//       }
//       _prefs.setString('webSocketUrl', _currentWsUrl);
//       _initializeWebSocket();
//     } else {
//       // URL is the same
//       _initializeWebSocket();
//       print('Closed WebSocket connection11');
//     }
//   }

//   void _endCurrentWebSocket() {
//     _channel?.sink.close(); // Close the WebSocket connection if it exists
//     _channel = null;
//     print('Closed WebSocket connection');
//   }

//   void _initializeWebSocket() {
//     _channel = WebSocketChannel.connect(Uri.parse(_currentWsUrl));
    
//     final Map<String, Map<String, dynamic>> ceSymbolsMap = {}; // Map to store symbols and LTP for CE
//     final Map<String, Map<String, dynamic>> peSymbolsMap = {}; // Map to store symbols and LTP for P
//     final Map<String, Map<String, dynamic>> indexSymbolsMap = {}; // Map to store symbols and LTP for INDEX

//     _channel?.stream.listen(
//       (message) {
//         final List<String> messages = (message as String).split('\n');

//       for (final msg in messages) {
//           try {
//             final sanitizedMsg = msg.replaceAll("'", '"');
//             final Map<String, dynamic> data = jsonDecode(sanitizedMsg);
//             final symbol = data['symbol'];
//             final ltp = data['ltp']?.toDouble(); // Assuming LTP is available and needs to be converted to double

//             // Extract the type (CE or PE) and the numerical part
//             final regex = RegExp(r'(\d+)(CE|PE)$');
//             final match = regex.firstMatch(symbol);

//             // Check if the symbol contains the word "INDEX"
//             if (symbol.contains("INDEX")) {
//               final formattedSymbol = symbol; // or format it if needed
//               final symbolData = {'symbol': formattedSymbol, 'ltp': ltp, 'code': symbol};
//               indexSymbolsMap[formattedSymbol] = symbolData;
//             } else if (match != null && ltp != null) {
//               final numericPart = match.group(1);
//               final typePart = match.group(2);

//               final formattedSymbol = '$numericPart $typePart';

//               final symbolData = {'symbol': formattedSymbol, 'ltp': ltp, 'code': symbol};

//               if (typePart == 'CE') {
//                 ceSymbolsMap[formattedSymbol] = symbolData;
//               } else if (typePart == 'PE') {
//                 peSymbolsMap[formattedSymbol] = symbolData;
//               }
//               print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: $indexSymbolsMap');
//             }
//           } catch (e) {
//             print('Error decoding JSON message: $e');
//           }
//         }

//         final List<Map<String, dynamic>> allCESymbols = ceSymbolsMap.values.toList();
//         final List<Map<String, dynamic>> allPESymbols = peSymbolsMap.values.toList();

//         allCESymbols.sort((a, b) => a['symbol'].compareTo(b['symbol']));
//         allPESymbols.sort((a, b) => b['symbol'].compareTo(a['symbol']));

//         final List<Map<String, dynamic>> top5CE = allCESymbols.take(5).toList();
//         final List<Map<String, dynamic>> top5PE = allPESymbols.take(5).toList();

//         setState(() {
//           _top5CESymbols = top5CE;
//           _top5PESymbols = top5PE;
//           _indexSymbol = indexSymbolsMap; 
//           _isLoading = false; // Set loading to false when data is fetched
//         });

//         print('Top 5 CE Symbols: $top5CE');
//         print('Top 5 PE Symbols: $top5PE');
//       },
//       onError: (error) {
//         if (kDebugMode) {
//           print('WebSocket error: $error');
//         }
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _endCurrentWebSocket();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Foreground content
//           Column(
//             children: <Widget>[
//               const SizedBox(height: 140),
//               CarouselExample(
//                 cardInfos: widget.cardInfos,
//                 data: _indexSymbol,
//                 height: widget.carouselHeight,
//               ),
//               SizedBox(height: 10),
//               if (_isLoading)
//                 Center(
//                   child: SpinKitFadingCircle(
//                     color: Colors.white,
//                     size: 50.0,
//                   ),
//                 ),
//               Expanded(
//                 child: CarouselSlider(
//                   options: CarouselOptions(
//                     enlargeCenterPage: true,
//                     height: MediaQuery.of(context).size.height * 1.0, // Adjust as needed
//                     viewportFraction: 0.95,
//                     enableInfiniteScroll: false, // Set to true if you want infinite scrolling
//                   ),
//                   items: [
//                     Container(
//                       color: Colors.green.withOpacity(0.1), // Green transparent background
//                       child: SpacedItemsList(
//                         listTileHeight: widget.listTileHeight,
//                         carouselWidth: widget.carouselWidth,
//                         items: _top5CESymbols, // Pass the list of CE symbols
//                       ),
//                     ),
//                     Container(
//                       color: Colors.red.withOpacity(0.1), // Red transparent background
//                       child: SpacedItemsList(
//                         listTileHeight: widget.listTileHeight,
//                         carouselWidth: widget.carouselWidth,
//                         items: _top5PESymbols, // Pass the list of PE symbols
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CarouselExample extends StatelessWidget {
//   const CarouselExample({
//     super.key,
//     required this.cardInfos,
//     required this.data,
//     required this.height,
//   });

//   final List<CardInfo> cardInfos;
//   final Map<String, Map<String, dynamic>> data;
//   final double height;

//   @override
//   Widget build(BuildContext context) {
//     return CarouselSlider(
//       options: CarouselOptions(
//         height: height,
//         viewportFraction: 0.95,
//         enlargeCenterPage: true,
//       ),
//       items: cardInfos.map((CardInfo info) {
//         return Builder(
//           builder: (BuildContext context) {
//             return ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: HeroLayoutCard(cardInfo: info, data: data,),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
// }



// class HeroLayoutCard extends StatelessWidget {
//   const HeroLayoutCard({
//     super.key,
//     required this.cardInfo,
//     required this.data,
//   });

//   final CardInfo cardInfo;
//   final Map<String, Map<String, dynamic>> data;

//   @override
//   Widget build(BuildContext context) {
//     final double width = MediaQuery.of(context).size.width;

//     // Convert the data map to a list of widgets for display
//     List<Widget> dataWidgets = data.entries.map((entry) {
//       final String key = entry.key;
//       final Map<String, dynamic> value = entry.value;
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'LTP: ${value['ltp']}',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge
//                   ?.copyWith(color: Colors.white),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               'Symbol: ${value['symbol']}',
//               style: Theme.of(context)
//                   .textTheme
//                   .bodyMedium
//                   ?.copyWith(color: Colors.white),
//             ),

//           ],
//         ),
//       );
//     }).toList();

//     return Container(
//       width: width * 0.95,
//       color: Color.fromARGB(243, 9, 9, 9),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Text(
//               cardInfo.title,
//               overflow: TextOverflow.clip,
//               softWrap: false,
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge
//                   ?.copyWith(color: Colors.white),
//             ),
//             const SizedBox(height: 8),
//             // Display all data entries
//             ...dataWidgets,
//           ],
//         ),
//       ),
//     );
//   }
// }



// class SpacedItemsList extends StatelessWidget {
//   final double listTileHeight;
//   final double carouselWidth;
//   final List<Map<String, dynamic>> items; // Accept list of items

//   const SpacedItemsList({
//     super.key,
//     required this.listTileHeight,
//     required this.carouselWidth,
//     required this.items,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: items.map((item) {
//           return Container(
//             width: carouselWidth,
//             margin: const EdgeInsets.symmetric(vertical: 0.1),
//             child: ItemWidget(
//               text: item['symbol'], // Use the symbol from the item
//               ltp: item['ltp'],
//               height: listTileHeight,
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class ItemWidget extends StatelessWidget {
//   const ItemWidget({
//     super.key,
//     required this.text,
//     required this.height,
//     required this.ltp,
//   });

//   final String text;
//   final double height;
//   final double ltp;

//   @override
//   Widget build(BuildContext context) {
//     final AudioPlayer _player = AudioPlayer();

//     void _playTapSound() async {
//       try {
//         await _player.setAudioSource(AudioSource.uri(
//           Uri.parse('https://example.com/tap_sound.mp3'), // Replace with your audio URL
//         ));
//         _player.play();
//       } catch (e) {
//         if (kDebugMode) {
//           print('Error loading audio source: $e');
//         }
//       }
//     }

//     final double buttonHeight = height * 0.75;
//     final double buttonWidth = 130;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 3.0),
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         color: Color.fromARGB(243, 9, 9, 9),
//         elevation: 0,
//         child: SizedBox(
//           height: height,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               SizedBox(
//                 width: buttonWidth,
//                 height: buttonHeight,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.withOpacity(0.9),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     // _playTapSound();
//                     // Add Buy button action here
//                   },
//                   child: const Text(
//                     'Buy',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   alignment: Alignment.center,
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center, // Center the badges horizontally
//                     children: [
//                       // Badge for Strike
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 3),
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[900], // Example color for LTP
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           text, // Pass Strike value here
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       // Badge for LTP
//                       Container(
//                         width: 50, // Fixed width for consistency
//                         height: 30,
//                         margin: const EdgeInsets.symmetric(horizontal: 3),
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.9),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Center( // Center the text within the container
//                           child: Text(
//                             ltp.toStringAsFixed(2).toString(), // Convert LTP to Integer and then to String
//                             style: const TextStyle(color: Colors.white),
//                             textAlign: TextAlign.center, // Center the text horizontally
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: buttonWidth,
//                 height: buttonHeight,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.withOpacity(0.9),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     // _playTapSound();
//                     // Add Sell button action here
//                   },
//                   child: const Text(
//                     'Sell',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum CardInfo {
//   dashBoard('Dashboard', 'Dashboard Overview status'),
//   midcpnifty('MIDCPNIFTY', 'Running : 42000'),
//   finnifty('FINNIFTY', 'Running : 34000'),
//   bankNifty('BANKNIFTY', 'Running : 52000'),
//   nifty('NIFTY', 'Running : 16000'),
//   portfolio('Portfolio : 25000', 'order Qty : 10');

//   const CardInfo(this.title, this.subtitle);
//   final String title;
//   final String subtitle;
// }

// const dashBoardCardInfo = [
//   CardInfo.dashBoard,
//   CardInfo.portfolio,
// ];

// const midcpNiftyCardInfo = [
//   CardInfo.midcpnifty,
//   CardInfo.portfolio,
// ];

// const finniftyCardInfo = [
//   CardInfo.finnifty,
//   CardInfo.portfolio,
// ];

// const bankNiftyCardInfo = [
//   CardInfo.bankNifty,
//   CardInfo.portfolio,
// ];

// const niftyCardInfo = [
//   CardInfo.nifty,
//   CardInfo.portfolio,
// ];

// const controlsCardInfo = [
//   CardInfo.portfolio,
// ];
