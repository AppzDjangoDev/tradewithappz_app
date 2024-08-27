import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart'; // For debugging purposes
import 'package:web_socket_channel/web_socket_channel.dart'; // For WebSocket communication
import 'package:shared_preferences/shared_preferences.dart'; // For shared preferences
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import the spinkit package
import 'package:elegant_notification/elegant_notification.dart'; // Ensure you have this package
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class BankniftyPage extends StatelessWidget {
  const BankniftyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OptionChainViewBanknifty(
      cardInfos: bankNiftyCardInfo,
      carouselHeight: MediaQuery.of(context).size.height * 0.19,
      listTileHeight: (MediaQuery.of(context).size.height - kToolbarHeight - (MediaQuery.of(context).size.height * 0.19) - 56) / 9,
      carouselWidth: MediaQuery.of(context).size.width * 0.95,
      webSocketUrl: 'wss://93bd-2401-4900-9078-8c79-6cba-2d1b-fdf9-d8c4.ngrok-free.app/ws/fyersindexdata/NIFTYBANK/',
    );
  }
}



class OptionChainViewBanknifty extends StatefulWidget {
  final List<CardInfo> cardInfos;
  final double carouselHeight;
  final double listTileHeight;
  final double carouselWidth;
  final String webSocketUrl;

  const OptionChainViewBanknifty({
    super.key,
    required this.cardInfos,
    required this.carouselHeight,
    required this.listTileHeight,
    required this.carouselWidth,
    required this.webSocketUrl,
  });

  @override
  _OptionChainViewBankniftyState createState() => _OptionChainViewBankniftyState();
}

class _OptionChainViewBankniftyState extends State<OptionChainViewBanknifty> {
  List<Map<String, dynamic>> _top5CESymbols = [];
  List<Map<String, dynamic>> _top5PESymbols = [];
  WebSocketChannel? _channel;
  late SharedPreferences _prefs;
  bool _isLoading = true;
  late String _currentWsUrl;
  Map<String, Map<String, dynamic>> _indexSymbol = {};

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    
    _webSocketManager();
  }

  void _webSocketManager() {
    _currentWsUrl = widget.webSocketUrl;

    String? storedUrl = _prefs.getString('webSocketUrl');
    
    if (storedUrl == null || storedUrl != _currentWsUrl) {
      if (storedUrl != null) {
        _endCurrentWebSocket();
      }
      _prefs.setString('webSocketUrl', _currentWsUrl);
      _initializeWebSocket();
    } else {
      _endCurrentWebSocket();
      _initializeWebSocket();
    }
  }

  void _endCurrentWebSocket() async {
    if (_channel != null) {
      // Send a disconnect message to the WebSocket server
      final disconnectMessage = json.encode({'action': 'disconnect'});
      _channel?.sink.add(disconnectMessage);

      // Optionally wait for a short period to ensure the server processes the disconnect message
      await Future.delayed(Duration(seconds: 5));

      // Close the WebSocket connection
      _channel?.sink.close();
      // _channel = null; // This is not necessary for a final field
    }
  }



  void _initializeWebSocket()async {
    _channel = WebSocketChannel.connect(Uri.parse(_currentWsUrl));
    
    final Map<String, Map<String, dynamic>> ceSymbolsMap = {};
    final Map<String, Map<String, dynamic>> peSymbolsMap = {};
    final Map<String, Map<String, dynamic>> indexSymbolsMap = {};

    _channel?.stream.listen(
      (message) {
        final List<String> messages = (message as String).split('\n');
        for (final msg in messages) {
          try {
            final sanitizedMsg = msg.replaceAll("'", '"');
            final Map<String, dynamic> data = jsonDecode(sanitizedMsg);
            final symbol = data['symbol'];
            final ltp = data['ltp']?.toDouble();

            final regex = RegExp(r'(\d+)(CE|PE)$');
            final match = regex.firstMatch(symbol);

            if (symbol.contains("INDEX")) {
              final symbolData = {'symbol': symbol, 'ltp': ltp, 'code': symbol};
              indexSymbolsMap[symbol] = symbolData;
            } else if (match != null && ltp != null) {
              final formattedSymbol = '${match.group(1)} ${match.group(2)}';
              // Ensure the string is at least 8 characters long
              final symbolLength = formattedSymbol.length;
              final startIndex = symbolLength > 8 ? symbolLength - 8 : 0;
              final slicedSymbol = formattedSymbol.substring(startIndex);

              final symbolData = {'symbol': slicedSymbol, 'ltp': ltp, 'code': symbol};

              if (match.group(2) == 'CE') {
                ceSymbolsMap[formattedSymbol] = symbolData;
              } else if (match.group(2) == 'PE') {
                peSymbolsMap[formattedSymbol] = symbolData;
              }
            }
          } catch (e) {
            print('Error decoding JSON message: $e');
          }
        }

        final List<Map<String, dynamic>> allCESymbols = ceSymbolsMap.values.toList();
        final List<Map<String, dynamic>> allPESymbols = peSymbolsMap.values.toList();

        allCESymbols.sort((a, b) => a['symbol'].compareTo(b['symbol']));
        allPESymbols.sort((a, b) => b['symbol'].compareTo(a['symbol']));

        setState(() {
          _top5CESymbols = allCESymbols.take(6).toList();
          _top5PESymbols = allPESymbols.take(6).toList();
          _indexSymbol = indexSymbolsMap;
          _isLoading = false;
        });
      },
      onError: (error) {
        if (kDebugMode) {
          print('WebSocket error: $error');
        }
      },
    );
  }

  @override
  void dispose() {
    _endCurrentWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              const SizedBox(height: 140),
              CarouselExample(
                cardInfos: widget.cardInfos,
                data: _indexSymbol,
                height: widget.carouselHeight,
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const Center(
                  child: SpinKitFadingCircle(
                    color: Colors.white,
                    size: 50.0,
                  ),
                ),
              Expanded(
                child: CarouselSlider(
                  options: CarouselOptions(
                    enlargeCenterPage: true,
                    height: MediaQuery.of(context).size.height * 1.0,
                    viewportFraction: 0.95,
                    enableInfiniteScroll: false,
                  ),
                  items: [
                    Container(
                      color: Colors.green.withOpacity(0.1),
                      child: SpacedItemsList(
                        listTileHeight: widget.listTileHeight,
                        carouselWidth: widget.carouselWidth,
                        items: _top5CESymbols,
                      ),
                    ),
                    Container(
                      color: Colors.red.withOpacity(0.1),
                      child: SpacedItemsList(
                        listTileHeight: widget.listTileHeight,
                        carouselWidth: widget.carouselWidth,
                        items: _top5PESymbols,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Additional classes like CarouselExample, HeroLayoutCard, SpacedItemsList, ItemWidget should be here as shown in your provided code.

class CarouselExample extends StatelessWidget {
  const CarouselExample({
    super.key,
    required this.cardInfos,
    required this.data,
    required this.height,
  });

  final List<CardInfo> cardInfos;
  final Map<String, Map<String, dynamic>> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        viewportFraction: 0.95,
        enlargeCenterPage: true,
      ),
      items: cardInfos.map((CardInfo info) {
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: HeroLayoutCard(cardInfo: info, data: data,),
            );
          },
        );
      }).toList(),
    );
  }
}



class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.cardInfo,
    required this.data,
  });

  final CardInfo cardInfo;
  final Map<String, Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    // Convert the data map to a list of widgets for display
    List<Widget> dataWidgets = data.entries.map((entry) {
      final String key = entry.key;
      final Map<String, dynamic> value = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LTP: ${value['ltp']}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              'Symbol: ${value['symbol']}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),

          ],
        ),
      );
    }).toList();

    return Container(
      width: width * 0.95,
      color: Color.fromARGB(243, 9, 9, 9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              cardInfo.title,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            // Display all data entries
            ...dataWidgets,
          ],
        ),
      ),
    );
  }
}


class SpacedItemsList extends StatelessWidget {
  final double listTileHeight;
  final double carouselWidth;
  final List<Map<String, dynamic>> items; // Accept list of items

  const SpacedItemsList({
    super.key,
    required this.listTileHeight,
    required this.carouselWidth,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> item = entry.value;
          
          // Determine if this is the last item
          bool isLastItem = index == items.length - 1;

          return Container(
            width: carouselWidth,
            margin: isLastItem
                ? const EdgeInsets.symmetric(vertical: 20.0) // Extra space before the last item
                : const EdgeInsets.symmetric(vertical: 0.1),
            child: ItemWidget(
              text: item['symbol'], // Use the symbol from the item
              ltp: item['ltp'],
              height: listTileHeight,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.text,
    required this.height,
    required this.ltp,
  });

  final String text;
  final double height;
  final double ltp;

  @override
  Widget build(BuildContext context) {
    final AudioPlayer _player = AudioPlayer();

    void _playTapSound() async {
      try {
        await _player.setAudioSource(AudioSource.uri(
          Uri.parse('https://example.com/tap_sound.mp3'), // Replace with your audio URL
        ));
        _player.play();
      } catch (e) {
        if (kDebugMode) {
          print('Error loading audio source: $e');
        }
      }
    }

    final double buttonHeight = height * 0.75;
    final double buttonWidth = 130;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Color.fromARGB(243, 9, 9, 9),
        elevation: 0,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _playTapSound();
                    // Add Buy button action here
                  },
                  child: const Text(
                    'Buy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center, // Center the badges horizontally
                    children: [
                      // Badge for Strike
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[900], // Example color for LTP
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          text, // Pass Strike value here
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      // Badge for LTP
                      Container(
                        width: 70, // Fixed width for consistency
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center( // Center the text within the container
                          child: Text(
                            ltp.toStringAsFixed(2).toString(), // Convert LTP to Integer and then to String
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center, // Center the text horizontally
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: ()async {
                        // _playTapSound();
                        try {
                          await deletePositions(context);
                          print('Positions deleted successfully');
                        } catch (e) {
                          print('Error deleting positions: $e');
                        }
                  },
                  child: const Text(
                    'Sell',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




Future<void> deletePositions(BuildContext context) async {
  await refreshAccessToken();
  final prefs = await SharedPreferences.getInstance();
  final appId = prefs.getString('client_id');
  final accessToken = prefs.getString('access_token');

  if (appId == null || accessToken == null) {
    throw Exception('Missing app_id or access_token');
  }

  final url = Uri.parse('https://api-t1.fyers.in/api/v3/positions');
  final headers = {
    'Authorization': '$appId:$accessToken',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'segment': [11],
    'side': [1, -1],
    'productType': ['INTRADAY', 'MARGIN'],
  });

  final response = await http.delete(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData['s'] == 'ok') {
      ElegantNotification.success(
        title: Text(
          'Success!',
          style: TextStyle(color: Colors.grey[200]),
        ),
        description: Text(
          responseData['message'],
          style: TextStyle(color: Colors.grey[200]),
        ),
        background: Color.fromARGB(243, 9, 9, 9),
        borderRadius: BorderRadius.circular(10),
      ).show(context);
    } else {
      ElegantNotification.error(
        title: Text(
          'Info',
          style: TextStyle(color: Colors.grey[200]),
        ),
        description: Text(
          '${responseData['message']}',
          style: TextStyle(color: Colors.grey[200]),
        ),
        background: Color.fromARGB(243, 9, 9, 9),
        borderRadius: BorderRadius.circular(10),
      ).show(context);
    }
  } else {
    ElegantNotification.error(
      title: Text(
        'Info',
        style: TextStyle(color: Colors.grey[300]),
      ),
      description: Text(
        '${response.statusCode} ${response.body}',
        style: TextStyle(color: Colors.grey[300]),
      ),
      background: Color.fromARGB(243, 9, 9, 9),
      borderRadius: BorderRadius.circular(20),
    ).show(context);
    throw Exception('Failed to delete positions');
  }
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
    print('Failed to refresh access token: ${response.statusCode} ${response.body}');
    throw Exception('Failed to refresh access token');
  }
}















enum CardInfo {
  dashBoard('Dashboard', 'Dashboard Overview status'),
  midcpnifty('MIDCPNIFTY', 'Running : 42000'),
  finnifty('FINNIFTY', 'Running : 34000'),
  bankNifty('BANKNIFTY', 'Running : 52000'),
  nifty('NIFTY', 'Running : 16000'),
  portfolio('Portfolio : 25000', 'order Qty : 10');

  const CardInfo(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

const dashBoardCardInfo = [
  CardInfo.dashBoard,
  CardInfo.portfolio,
];

const midcpNiftyCardInfo = [
  CardInfo.midcpnifty,
  CardInfo.portfolio,
];

const finniftyCardInfo = [
  CardInfo.finnifty,
  CardInfo.portfolio,
];

const bankNiftyCardInfo = [
  CardInfo.bankNifty,
  CardInfo.portfolio,
];

const niftyCardInfo = [
  CardInfo.nifty,
  CardInfo.portfolio,
];

const controlsCardInfo = [
  CardInfo.portfolio,
];
