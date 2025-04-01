import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/auth/splash_page.dart';
import 'package:urban_treasure/models/themes_notifier.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://vtsdaeaxlcwwbgdpvjrd.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0c2RhZWF4bGN3d2JnZHB2anJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExOTY0OTMsImV4cCI6MjA1Njc3MjQ5M30.ID5oY0A9mp-bXB7pOWwQdloX78C9h90C8l9bKXwjGeA",
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MainApp(),
    ),
  );
}

// Global variable to access the Supabase client
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.themeMode,
      home: const SplashPage(), // SplashPage handles loading + redirects
    );
  }
}
