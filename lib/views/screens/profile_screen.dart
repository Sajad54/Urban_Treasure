import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  bool isMfaEnabled = false;
  String? _mfaFactorId;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _checkMfaStatus();
  }

  Future<void> _fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('username, mfa_enabled')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _username = response['username'];
          isMfaEnabled = response['mfa_enabled'] ?? false;
        });
      }
    }
  }

  Future<void> _checkMfaStatus() async {
    final response = await Supabase.instance.client.auth.mfa.listFactors();
    final totpFactors = response.totp;
    if (totpFactors.isNotEmpty) {
      setState(() {
        isMfaEnabled = true;
        _mfaFactorId = totpFactors.first.id;
      });
    }
  }

  Future<void> _toggleMfa(bool enable) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (enable) {
      try {
        final response = await Supabase.instance.client.auth.mfa.enroll(
          factorType: FactorType.totp,
          friendlyName: 'TOTP-${DateTime.now().millisecondsSinceEpoch}',
        );

        final uri = response.totp?.uri;
        final factorId = response.id;

        if (uri != null && mounted) {
          setState(() {
            isMfaEnabled = true;
            _mfaFactorId = factorId;
          });

          await Supabase.instance.client
              .from('profiles')
              .update({'mfa_enabled': true}).eq('id', user.id);

          final otpController = TextEditingController();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Set Up MFA"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(data: uri, size: 200),
                    const SizedBox(height: 12),
                    const Text("Scan this code in your Authenticator app"),
                    const SizedBox(height: 20),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter 6-digit code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final otp = otpController.text.trim();
                    if (otp.isEmpty) return;

                    try {
                      final challenge = await Supabase.instance.client.auth.mfa
                          .challenge(factorId: factorId);

                      await Supabase.instance.client.auth.mfa.verify(
                        factorId: factorId,
                        challengeId: challenge.id,
                        code: otp,
                      );

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("MFA setup complete!")),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Verification failed: $e")),
                      );
                    }
                  },
                  child: const Text("Verify"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        debugPrint("Error enrolling in MFA: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to enable MFA: $e")),
        );
      }
    } else {
      if (_mfaFactorId != null) {
        try {
          await Supabase.instance.client.auth.mfa.unenroll(_mfaFactorId!);
          await Supabase.instance.client
              .from('profiles')
              .update({'mfa_enabled': false}).eq('id', user.id);

          setState(() {
            isMfaEnabled = false;
            _mfaFactorId = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("MFA disabled successfully")),
          );
        } catch (e) {
          debugPrint("Error unenrolling from MFA: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to disable MFA: $e")),
          );
        }
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
            const Text('Preferred Business Category:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: <String>['Food', 'Clothes', 'Skin/Body Care', 'Crafts']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 30),
            const Text('Search Radius (in miles):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedRadius,
              isExpanded: true,
              items: <String>['5 miles', '10 miles', '20 miles']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedRadius = value!);
              },
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeNotifier.themeMode == ThemeMode.dark,
              onChanged: (_) => themeNotifier.toggleTheme(),
            ),
            SwitchListTile(
              title: const Text('Enable MFA'),
              value: isMfaEnabled,
              onChanged: (value) => _toggleMfa(value),
            ),
          ],
        ),
      ),
    );
  }
}
