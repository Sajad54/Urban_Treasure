import 'package:flutter/material.dart';
import 'package:urban_treasure/main.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';
import 'package:urban_treasure/views/screens/profile_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    // Initial setup, no context-dependent logic here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // It's now safe to interact with context here
    _redirect();
  }

  // Redirects user based on sign-in state
  Future<void> _redirect() async {
    try {
      final session = supabase.auth.currentSession;
      if (!mounted) return; // Check if the widget is still mounted

      // Add a small delay to ensure previous navigation actions are completed
      await Future.delayed(Duration(milliseconds: 100));

      if (session != null) {
        // Navigate to ProfileScreen if authenticated
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      } else {
        // Navigate to LoginScreen if unauthenticated
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Delay the SnackBar display until the Scaffold is available
      Future.delayed(Duration.zero, () {
        // Handle any error that may occur during session check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
