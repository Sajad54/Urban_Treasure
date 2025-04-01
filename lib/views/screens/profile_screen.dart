import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/controllers/auth_controller.dart';
import 'package:urban_treasure/models/themes_notifier.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authController = AuthController();
  String? _username;
  String _selectedCategory = 'Food';
  String _selectedRadius = '5 miles';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _username = response['username'];
        });
      }
    }
  }

  void logout() async {
    await authController.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void goBackToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBackToHome,
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                _username != null ? 'Welcome $_username!' : 'Loading...',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),

            // Business Category Dropdown
            const Text(
              'Preferred Business Category:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: <String>['Food', 'Clothes', 'Skin/Body Care', 'Crafts']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            // Radius Dropdown
            const Text(
              'Search Radius (in miles):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedRadius,
              isExpanded: true,
              items: <String>['5 miles', '10 miles', '20 miles']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRadius = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            // Dark Mode Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeNotifier.themeMode == ThemeMode.dark,
              onChanged: (_) {
                themeNotifier.toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }
}
