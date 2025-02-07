import 'dart:io';
import 'package:flutter/material.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isIOS?await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: 'AIzaSyBiXHoh3FdEh_RwIZxLdME_c6gxj65fIUg', 
    appId: '1:173922897650:ios:85cb368c80cc7b5ea50a6b', 
    messagingSenderId: '173922897650', 
    projectId: 'urbantreasure-f74d9',
    storageBucket: 'gs://urbantreasure-f74d9.firebasestorage.app'),
    )
    : await Firebase.initializeApp();

  Platform.isAndroid?await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: 'AIzaSyAZW2tf6pYgMxM5NZDK5YV8gB-Z-afk_mM', 
    appId: '1:173922897650:android:0a0c3223fe2e1423a50a6b', 
    messagingSenderId: '173922897650', 
    projectId: 'urbantreasure-f74d9',
    storageBucket: 'gs://urbantreasure-f74d9.firebasestorage.app'),
    )
    : await Firebase.initializeApp();
  runApp(const MainApp());
 }

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
