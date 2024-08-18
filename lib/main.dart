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
