import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

class WidgetHome extends StatelessWidget {
  const WidgetHome({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    final double availableHeight = screenHeight - appBarHeight;
    final double carouselHeight = availableHeight * 0.178;
    final double cardHeight = (availableHeight - carouselHeight) / 6.5;
    final double cardWidth = MediaQuery.of(context).size.width * 0.25;
    final Color cardColor = const Color.fromARGB(243, 9, 9, 9);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([fetchFundData(), fetchTotalOrdersWithStatus2(), fetchTradeConfigurations()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        } else if (snapshot.hasError) {
          return _buildErrorScreen();
        }

        final profileData = snapshot.data?[0];
        final orderCount = snapshot.data?[1] as int;
        final tradeConfig = snapshot.data?[2] as Map<String, dynamic>;

        final List<dynamic> fundData = profileData?['fund_limit'] ?? [];
        final availableBalance = _getFundValue(fundData, 'Available Balance');
        final openingBalance = _getFundValue(fundData, 'Limit at start of the day');
        final realizedProfitAndLoss = _getFundValue(fundData, 'Realized Profit and Loss');
        final utilizedAmount = _getFundValue(fundData, 'Utilized Amount');
        final fundTransfer = _getFundValue(fundData, 'Fund Transfer');

        return _buildMainScreen(context, carouselHeight, cardHeight, cardWidth, cardColor, 
            availableBalance, realizedProfitAndLoss, utilizedAmount, fundTransfer, openingBalance, orderCount, tradeConfig);
      },
    );
  }

  double _getFundValue(List<dynamic> fundData, String title) {
    return (fundData.firstWhere((fund) => fund['title'] == title, orElse: () => {'equityAmount': 0})['equityAmount'] as num).toDouble();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          const Center(child: SpinKitFadingCircle(color: Colors.white, size: 50.0)),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Center(
            child: ElevatedButton(
              onPressed: () => _launchUrl('https://605f-2401-4900-9078-8c79-bd3f-d02b-6652-c8ea.ngrok-free.app/login'),
              child: const Text('FYERS LOGIN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1618123069754-cd64c230a169?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmxhY2slMjB0ZXh0dXJlfGVufDB8fDB8fHww'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context, double carouselHeight, double cardHeight, double cardWidth, Color cardColor, 
      double availableBalance, double realizedProfitAndLoss, double utilizedAmount, double fundTransfer, double openingBalance, int orderCount, Map<String, dynamic> tradeConfig) {
    final List<Widget> carouselItems = [
      _buildFirstCarouselItem(availableBalance, realizedProfitAndLoss, cardColor),
      _buildSecondCarouselItem(utilizedAmount, fundTransfer, openingBalance, cardColor),
    ];

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Column(
            children: [
              const SizedBox(height: 125),
              _buildCarousel(carouselHeight, carouselItems),
              const SizedBox(height: 10),
              _buildGridView(cardHeight, cardWidth, cardColor, availableBalance, realizedProfitAndLoss, openingBalance, orderCount, tradeConfig),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(double carouselHeight, List<Widget> carouselItems) {
    return Container(
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
    );
  }

  Widget _buildGridView(double cardHeight, double cardWidth, Color cardColor, double availableBalance, double realizedProfitAndLoss, double openingBalance, int orderCount, Map<String, dynamic> tradeConfig) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: cardWidth / cardHeight,
        ),
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          return _buildDashboardCard(index, cardColor, realizedProfitAndLoss, availableBalance, openingBalance, orderCount, tradeConfig, cardWidth, cardHeight);
        },
      ),
    );
  }

  Widget _buildDashboardCard(int index, Color cardColor, double realizedProfitAndLoss, double availableBalance, double openingBalance, int orderCount, Map<String, dynamic> tradeConfig, double cardWidth, double cardHeight) {
    double width = (index == 0 || index == 1) ? cardWidth * 2 : cardWidth;
    
    return SizedBox(
      width: width,
      height: cardHeight,
      child: DashboardCard(
        index: index,
        cardColor: cardColor,
        realizedProfitAndLoss: realizedProfitAndLoss,
        availableBalance: index == 2 ? availableBalance : 0.0,
        opening_balance: index == 3 ? openingBalance : 0.0,
        orderCount: index == 4 ? orderCount : 0,
        tradeConfig: tradeConfig,
      ),
    );
  }

  Widget _buildFirstCarouselItem(double availableBalance, double realizedProfitAndLoss, Color color) {
    return _buildCarouselContainer(color, [
      'Available Balance: $availableBalance',
      'Realized Profit and Loss: $realizedProfitAndLoss',
    ]);
  }

  Widget _buildSecondCarouselItem(double utilizedAmount, double fundTransfer, double limitAtStartOfDay, Color color) {
    return _buildCarouselContainer(color, [
      'Utilized Amount: $utilizedAmount',
      'Fund Transfer: $fundTransfer',
      'Limit at Start of the Day: $limitAtStartOfDay',
    ]);
  }

  Widget _buildCarouselContainer(Color color, List<String> texts) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: texts.map((text) => Text(text, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold))).toList(),
            ),
          ),
        ],
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

    if (response.statusCode == 200) {
      final newAccessToken = json.decode(response.body)['access_token'];
      prefs.setString('access_token', newAccessToken);
    } else {
      throw Exception('Failed to refresh access token');
    }
  }

  Future<Map<String, dynamic>> fetchFundData() async {
    await refreshAccessToken();
    final prefs = await SharedPreferences.getInstance();
    final appId = prefs.getString('client_id');
    final accessToken = prefs.getString('access_token');

    if (appId == null || accessToken == null) {
      throw Exception('Missing app_id or access_token');
    }

    final url = Uri.parse('https://api-t1.fyers.in/api/v3/funds');
    final response = await http.get(url, headers: {'Authorization': '$appId:$accessToken'});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch profile data');
    }
  }

  Future<int> fetchTotalOrdersWithStatus2() async {
    await refreshAccessToken();
    final prefs = await SharedPreferences.getInstance();
    final appId = prefs.getString('client_id');
    final accessToken = prefs.getString('access_token');

    if (appId == null || accessToken == null) {
      throw Exception('Missing app_id or access_token');
    }

    final url = Uri.parse('https://api-t1.fyers.in/api/v3/orders');
    final response = await http.get(url, headers: {'Authorization': '$appId:$accessToken'});

    if (response.statusCode == 200) {
      final List<dynamic> orders = json.decode(response.body)['orderBook'] ?? [];
      return orders.where((order) => order['status'] == 2).length;
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  Future<Map<String, dynamic>> fetchTradeConfigurations() async {
    final url = Uri.parse('https://605f-2401-4900-9078-8c79-bd3f-d02b-6652-c8ea.ngrok-free.app/api/fetch-trade-configurations');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch trade configurations');
    }
  }
}

class DashboardCard extends StatelessWidget {
  final int index;
  final Color cardColor;
  final double realizedProfitAndLoss;
  final double availableBalance;
  final double opening_balance;
  final int orderCount;
  final Map<String, dynamic> tradeConfig;

  const DashboardCard({
    Key? key,
    required this.index,
    required this.cardColor,
    this.realizedProfitAndLoss = 0.0,
    this.availableBalance = 0.0,
    this.opening_balance = 0.0,
    this.orderCount = 0,
    required this.tradeConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: index == 11 ? _fetchAndUpdateConfigurations : null,
      child: Container(
        height: 150.0,
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Icon(
                _getIconData(),
                color: _getIconColor(),
                size: 24.0,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_getValueText(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.0)),
                    const SizedBox(height: 6.0),
                    Text(_getLabelText(), style: const TextStyle(color: Colors.white, fontSize: 14.0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (index) {
      case 0:
        return realizedProfitAndLoss >= 0 ? Icons.trending_up : Icons.trending_down;
      case 1:
        return realizedProfitAndLoss <= 0 ? Icons.trending_down : Icons.trending_up;
      case 2:
        return Icons.attach_money;
      case 3:
        return Icons.account_balance_wallet;
      case 4:
        return Icons.unarchive;
      case 5:
        return Icons.payments;
      case 6:
        return Icons.account_balance;
      case 7:
        return Icons.notifications;
      case 8:
        return Icons.access_time;
      case 9:
        return Icons.account_balance;
      case 10:
        return Icons.login;
      case 11:
        return Icons.refresh;
      case 5: // max_trade_count
        return Icons.list; 
      case 6: // default_stoploss
        return Icons.warning; 
      case 7: // default_order_qty
        return Icons.check_circle; 
      case 8: // max_loss
        return Icons.money_off; 
      case 9: // averaging_qty
        return Icons.equalizer; 
      case 10: // last_updated
        return Icons.update; 
      default:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (index) {
      case 0:
      case 1:
        return Colors.blueAccent; // Profit/Loss
      case 2:
        return Colors.green; // Available Balance
      case 3:
        return Colors.orange; // Opening Balance
      case 4:
        return Colors.purple; // Traded Orders
      case 5:
        return Colors.teal; // Max Trade Count
      case 6:
        return Colors.red; // Default Stoploss
      case 7:
        return Colors.lightBlue; // Default Order Qty
      case 8:
        return Colors.deepOrange; // Max Loss
      case 9:
        return Colors.cyan; // Averaging Qty
      case 10:
        return Colors.grey; // Last Updated
      case 11:
        return Colors.blue; // Refresh
      default:
        return Colors.grey; // Default color for other cases
    }
  }

  String _getValueText() {
    switch (index) {
      case 0:
      case 1:
        return '$realizedProfitAndLoss';
      case 2:
        return '$availableBalance';
      case 3:
        return '$opening_balance';
      case 4:
        return '$orderCount';
      case 5:
        return '${tradeConfig['max_trade_count']}';
      case 6:
        return '${tradeConfig['default_stoploss']}';
      case 7:
        return '${tradeConfig['default_order_qty']}';
      case 8:
        return '${tradeConfig['max_loss']}';
      case 9:
        return '${tradeConfig['averaging_qty']}';
      case 10:
        return formatDate(tradeConfig['last_updated']); // Format the date
      case 11:
        return 'Refresh';
      default:
        return 'N/A';
    }
  }

  String formatDate(String dateTime) {
    final DateTime date = DateTime.parse(dateTime);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'; // Format to YYYY-MM-DD
  }

  String _getLabelText() {
    switch (index) {
      case 0:
        return 'Profit Status';
      case 1:
        return 'Loss Status';
      case 2:
        return 'Available Balance';
      case 3:
        return 'Opening Balance';
      case 4:
        return 'Traded Orders';
      case 5:
        return 'Max Trade Count';
      case 6:
        return 'Default Stoploss';
      case 7:
        return 'Default Order Qty';
      case 8:
        return 'Max Loss';
      case 9:
        return 'Averaging Qty';
      case 10:
        return 'Last Updated';
      case 11:
        return 'Update Controls';
      default:
        return 'Other Card';
    }
  }

  Future<void> _fetchAndUpdateConfigurations() async {
    const url = 'https://605f-2401-4900-9078-8c79-bd3f-d02b-6652-c8ea.ngrok-free.app/api/fetch-trade-configurations';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final configData = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('tradingConfigurations', json.encode(configData));
        print('Configuration updated successfully! $configData');
      } else {
        print('Failed to load configurations');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
}

Future<void> _launchUrl(String? url) async {
  if (url == null) {
    print('URL is null');
    return;
  }

  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}