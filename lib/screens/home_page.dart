import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme_notifier.dart';
import 'option_chain_view.dart';
import 'widgethome.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _csrfToken = ''; // Store the CSRF token

  static const List<String> _titles = [
    'DASHBOARD',
    'MIDCPNIFTY',
    'FINNIFTY',
    'BANKNIFTY',
    'NIFTY',
    'CONTROLS',
  ];

  static const List<List<CardInfo>> _cardInfos = [
    dashBoardCardInfo,
    midcpNiftyCardInfo,
    finniftyCardInfo,
    bankNiftyCardInfo,
    niftyCardInfo,
    controlsCardInfo,
  ];

  @override
  void initState() {
    super.initState();
    _retrieveCSRFToken(); // Fetch CSRF token when the widget initializes
  }

  Future<void> _retrieveCSRFToken() async {
    final url = 'https://65c7-2401-4900-6472-7006-dd5-104c-63b9-fed2.ngrok-free.app/api/csrf-token/'; // Replace with your actual CSRF endpoint
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        setState(() {
          _csrfToken = _extractCSRFToken(cookies);
        });
        print('CSRF Token retrieved successfully: $_csrfToken');
      } else {
        throw Exception('Failed to retrieve CSRF token');
      }
    } catch (e) {
      print('Error retrieving CSRF token: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving CSRF token. Please try again later.')),
      );
    }
  }

  String _extractCSRFToken(String? cookies) {
    final csrfTokenPattern = RegExp(r'csrftoken=([^;]+)');
    final match = csrfTokenPattern.firstMatch(cookies ?? '');
    return match?.group(1) ?? '';
  }

  Future<void> _logout() async {
    try {
      final url = 'https://65c7-2401-4900-6472-7006-dd5-104c-63b9-fed2.ngrok-free.app/api/logout/';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': _csrfToken, // Include the CSRF token
          'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // Handle successful logout
          Navigator.pushReplacementNamed(context, '/login');
          var box = await Hive.openBox('app_log');
          await box.clear();
        } else {
          // Handle logout failure
          print('Logout failed. Response status: ${response.statusCode}');
          print('Response body: ${response.body}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed. Please try again.')),
          );
        }
      } catch (e) {
        // Handle exception during logout
        print('Logout failed with exception: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during logout. Please try again.')),
        );
      }
    }

  // Future<void> _logout() async {
  //   try {
  //     final url = 'https://65c7-2401-4900-6472-7006-dd5-104c-63b9-fed2.ngrok-free.app/api/logout/';
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'X-CSRFToken': _csrfToken,
  //         'Accept': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       Navigator.pushReplacementNamed(context, '/login');
  //       var box = await Hive.openBox('app_log');
  //       await box.clear();
  //     } else {
  //       print('Logout failed. Response status: ${response.statusCode}');
  //       print('Response body: ${response.body}');

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Logout failed. Please try again.')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Logout failed with exception: $e');

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('An error occurred during logout. Please try again.')),
  //     );
  //   }
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(_titles[_selectedIndex]),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              themeNotifier.themeMode == ThemeMode.dark
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
            ),
            onPressed: () {
              themeNotifier.setThemeMode(
                themeNotifier.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 25.0),
            child: CircleAvatar(child: Icon(Icons.account_circle)),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                image: DecorationImage(
                  image: AssetImage('assets/images/menu_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: const Text('Dark Mode Toggle'),
              onTap: () {
                Navigator.pop(context);
                themeNotifier.setThemeMode(
                  themeNotifier.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Trading Configuration'),
              onTap: () {
                Navigator.pop(context);
                // Add your action for trading configuration here
              },
            ),
            ListTile(
              leading: const Icon(Icons.developer_mode),
              title: const Text('Developer Settings'),
              onTap: () {
                Navigator.pop(context);
                // Add your action for developer settings here
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                Navigator.pop(context);
                await _logout();
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenHeight = constraints.maxHeight;
          final double appBarHeight = kToolbarHeight;
          final double carouselHeight = screenHeight * 0.19;
          final double listTileHeight = (screenHeight - appBarHeight - carouselHeight) / 9;
          final double carouselWidth = constraints.maxWidth * 0.95;

          return _selectedIndex == 0
              ? const WidgetHome()
              : OptionChainView(
                  cardInfos: _cardInfos[_selectedIndex],
                  carouselHeight: carouselHeight,
                  listTileHeight: listTileHeight,
                  carouselWidth: carouselWidth,
                );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'MIDCPNIFTY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'FINNIFTY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'BANKNIFTY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'NIFTY',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
