import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/auth/splash_page.dart';

void main() async {
  // Initialize Supabase before the app starts
  await Supabase.initialize(
    url: "https://vtsdaeaxlcwwbgdpvjrd.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0c2RhZWF4bGN3d2JnZHB2anJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExOTY0OTMsImV4cCI6MjA1Njc3MjQ5M30.ID5oY0A9mp-bXB7pOWwQdloX78C9h90C8l9bKXwjGeA",
  );
  runApp(MainApp());
}

// Global variable to access the Supabase client
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(), // SplashPage should handle loading and redirect
    );
  }
}
