import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import the spinkit package
import '../theme_notifier.dart';
import 'widgethome.dart';
import 'profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'controls.dart'; // Import the Controls page
import 'midcap_nifty_page.dart'; // Ensure this path is correct
import 'finnifty_page.dart'; // Ensure this path is correct
import 'banknifty_page.dart'; // Ensure this path is correct
import 'nifty_page.dart'; // Ensure this path is correct

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _csrfToken = ''; // Store the CSRF token
  bool _isLoading = true; // State to track loading
  bool _dashboardVisited = true; // Track if the dashboard has been visited

  static const List<String> _titles = [
    'Dashboard',
    'Midcap Nifty',
    'Finnifty',
    'Banknifty',
    'Nifty',
    'Controls',
  ];

  // List of icons for the bottom navigation items
  final List<IconData> _icons = [
    Icons.home,  // Dashboard
    Icons.bar_chart, // Midcap Nifty
    Icons.pie_chart, // Fin Nifty
    Icons.attach_money, // BANKNIFTY
    Icons.trending_up, // Nifty
    Icons.settings, // Controls 
  ];

  @override
  void initState() {
    super.initState();
    _retrieveCSRFToken(); // Fetch CSRF token when the widget initializes
  }

  Future<void> _retrieveCSRFToken() async {
    final url =
        'https://93bd-2401-4900-9078-8c79-6cba-2d1b-fdf9-d8c4.ngrok-free.app/api/csrf-token/'; // Replace with your actual CSRF endpoint
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        setState(() {
          _csrfToken = _extractCSRFToken(cookies);
          _isLoading = false; // Set loading to false when done
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
      final url = 'https://93bd-2401-4900-9078-8c79-6cba-2d1b-fdf9-d8c4.ngrok-free.app/api/logout/';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': _csrfToken, // Include the CSRF token
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Clear Hive box
        final appLogBox = await Hive.openBox('app_log');
        await appLogBox.clear();

        // Clear shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Navigate to login page
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print('Logout failed. Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    } catch (e) {
      print('Logout failed with exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during logout. Please try again.')),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // If the user navigates to the dashboard, reset the flags
      setState(() {
        _selectedIndex = index;
        _dashboardVisited = true;
      });
    } else if (_dashboardVisited && index > 0) {
      // Allow navigation to other pages only if the dashboard has been visited
      setState(() {
        _selectedIndex = index;
        _dashboardVisited = false; // Disable further navigation to other pages
      });
    } else {
      // If not allowed, reset to dashboard
      // setState(() {
      //   _selectedIndex = index;
      // });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please visit the Dashboard before navigating to other pages.'),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    Widget _getPage(int index) {
      switch (index) {
        case 0:
          return const WidgetHome();
        case 1:
          return const MidcapNiftyPage();
        case 2:
          return const FinniftyPage();
        case 3:
          return const BankniftyPage();
        case 4:
          return const NiftyPage();
        case 5:
          return const ControlsPage();
        default:
          return const WidgetHome();
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.transparent, // Set the drawer background to transparent
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95), // Add a semi-transparent background to the entire drawer
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95), // Apply the same semi-transparent background
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Menu',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
      ),
      body: Stack(
        children: [
          _getPage(_selectedIndex),
          if (_isLoading)
            Center(
              child: SpinKitFadingCircle(
                color: Colors.white,
                size: 50.0,
              ),
            ),
          Positioned(
            top: 60,
            left: 16,
            child: FloatingActionButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.account_circle, color: Colors.white),
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
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  _titles[_selectedIndex],
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
      bottomNavigationBar: SalomonBottomBar(
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        items: List.generate(_titles.length, (index) {
          return SalomonBottomBarItem(
            icon: index == 0
                ? SizedBox(
                    width: 34.0, // Adjust the size as needed
                    height: 34.0,
                    child: Icon(_icons[index], size: 34.0), // Adjust the size as needed
                  )
                : Icon(_icons[index]),
            title: Text(_titles[index]),
            selectedColor: Colors.blue,
          );
        }),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

