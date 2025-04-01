import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
  await Future.delayed(const Duration(seconds: 2));

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (!mounted) return;

  if (user == null) {
    // No logged-in user
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    return;
  }

  try {
    // If user exists, refresh session
    await supabase.auth.refreshSession();

    // Then go to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } catch (e) {
    debugPrint("Splash error: $e");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
