import 'package:flutter/material.dart';
import 'package:urban_treasure/controllers/auth_controller.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // get auth service
  final authController = AuthController();

  // logout button pressed
  void logout() async {
  await authController.signOut();
  
  // Navigate to login screen after logout
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),  // replace with your login screen
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
      actions: [
        //logout button
        IconButton(
          onPressed: logout, 
          icon: const Icon(Icons.logout))
      ],
      ),
    );
  }
  
}