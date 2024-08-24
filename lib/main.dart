// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'models/app_log.dart';
// import 'models/trading_configuration.dart';
// import 'theme_notifier.dart';
// import 'screens/home_page.dart';
// import 'screens/login_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Initialize Hive
//   await Hive.initFlutter();

//   // Register Hive adapters
//   Hive.registerAdapter(AppLogAdapter());
//   Hive.registerAdapter(TradingConfigurationAdapter());

//   // Open Hive boxes
//   await Hive.openBox<AppLog>('app_log_box');
//   await Hive.openBox<TradingConfiguration>('trading_configuration_box');

//   // Check login status
//   final prefs = await SharedPreferences.getInstance();
//   final bool isLoggedIn = prefs.getString('access_token') != null;

//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => ThemeNotifier(),
//       child: MyApp(isLoggedIn: isLoggedIn),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   final bool isLoggedIn;

//   const MyApp({super.key, required this.isLoggedIn});

//   @override
//   Widget build(BuildContext context) {
//     final themeNotifier = Provider.of<ThemeNotifier>(context);

//     return MaterialApp(
//       title: 'Flutter Demo',
//       themeMode: themeNotifier.themeMode,
//       darkTheme: ThemeData.dark().copyWith(
//         textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
//       ),
//       theme: ThemeData.light().copyWith(
//         textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
//       ),
//       initialRoute: isLoggedIn ? '/home' : '/login',
//       routes: {
//         '/login': (context) => const BackgroundContainer(child: LoginPage()),
//         '/home': (context) => const BackgroundContainer(child: HomePage()),
//       },
//     );
//   }
// }

// class BackgroundContainer extends StatelessWidget {
//   final Widget child;

//   const BackgroundContainer({Key? key, required this.child}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
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
//           child,
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/app_log.dart';
import 'models/trading_configuration.dart';
import 'theme_notifier.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart'; // Import for sha256
import 'dart:convert'; // Import for utf8 and json encoding
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(AppLogAdapter());
  Hive.registerAdapter(TradingConfigurationAdapter());

  // Open Hive boxes
  await Hive.openBox<AppLog>('app_log_box');
  await Hive.openBox<TradingConfiguration>('trading_configuration_box');

  // Refresh the access token before checking login status
  try {
    await refreshAccessToken();
  } catch (e) {
    print('Error refreshing access token: $e');
  }

  // Check login status
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getString('access_token') != null;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(isLoggedIn: isLoggedIn),
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

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: themeNotifier.themeMode,
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
      ),
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const BackgroundContainer(child: LoginPage()),
        '/home': (context) => const BackgroundContainer(child: HomePage()),
      },
    );
  }
}

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
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
          child,
        ],
      ),
    );
  }
}
