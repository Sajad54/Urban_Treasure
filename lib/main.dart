import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';

void main() async{
  await Supabase.initialize(
    anonKey:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0c2RhZWF4bGN3d2JnZHB2anJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExOTY0OTMsImV4cCI6MjA1Njc3MjQ5M30.ID5oY0A9mp-bXB7pOWwQdloX78C9h90C8l9bKXwjGeA" ,
    url:"https://vtsdaeaxlcwwbgdpvjrd.supabase.co"
  );
  runApp(MainApp());
 }

class MainApp extends StatelessWidget {
   MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
