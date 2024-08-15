import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import 'package:hive_flutter/hive_flutter.dart'; // Import hive_flutter for Hive
import 'models/app_log.dart'; // Import your AppLog model
import 'models/trading_configuration.dart'; // Import your TradingConfiguration model
import 'theme_notifier.dart'; // Import your ThemeNotifier class
import 'screens/home_page.dart'; // Import your HomePage
import 'screens/login_page.dart'; // Import your LoginPage

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

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // Initialize ThemeNotifier
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
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
      initialRoute: '/login', // Set the initial route to the login page
      routes: {
        '/login': (context) => const LoginPage(), // Define the login page route
        '/home': (context) => const HomePage(), // Define the home page route
      },
    );
  }
}
