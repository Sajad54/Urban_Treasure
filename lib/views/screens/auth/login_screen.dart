import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/main.dart';
import 'package:urban_treasure/views/screens/auth/register_screen.dart';
import 'package:urban_treasure/views/screens/auth/business_register_screen.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _mfaFactorId;
  String? _challengeId;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        final result = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final user = result.user;

        if (result.session != null) {
          final profile = await supabase
              .from('profiles')
              .select()
              .eq('id', user!.id)
              .maybeSingle();

          if (profile == null) {
            await supabase.auth.signOut();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No profile found. Please register again.")),
            );
            return;
          }

          final isMfaEnabled = profile['mfa_enabled'] ?? false;

          if (isMfaEnabled) {
            final factors = await supabase.auth.mfa.listFactors();
            final totpFactor = factors.totp.firstOrNull;

            if (totpFactor == null) throw Exception("TOTP factor not found.");

            final challenge = await supabase.auth.mfa.challenge(factorId: totpFactor.id);

            _mfaFactorId = totpFactor.id;
            _challengeId = challenge.id;

            if (!mounted) return;

            await _showOtpDialog(); // Ask for the code inline
          } else {
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          }
        } else if (user != null) {
          throw Exception("Unexpected login state. MFA likely required but session is null.");
        } else {
          throw Exception('Login failed.');
        }
      } on AuthApiException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auth error: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showOtpDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Enter 6-digit code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the code from your authenticator app"),
              const SizedBox(height: 10),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "6-digit code",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final code = _otpController.text.trim();

                  if (_mfaFactorId == null || _challengeId == null) {
                    throw Exception("Missing MFA factor or challenge ID");
                  }

                  await supabase.auth.mfa.verify(
                    factorId: _mfaFactorId!,
                    challengeId: _challengeId!,
                    code: code,
                  );

                  final refreshed = await supabase.auth.refreshSession();
                  if (refreshed.session == null) {
                    throw Exception("Failed to refresh session after verification");
                  }

                  if (!mounted) return;
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invalid code: $e")),
                  );
                }
              },
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 60, left: 14, right: 14),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Account Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4)),
              const SizedBox(height: 25),
              TextFormField(
                controller: _emailController,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a valid email' : null,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 221, 178, 49)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a valid password' : null,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 221, 178, 49)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 4, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width - 75, 50),
                  backgroundColor: const Color.fromARGB(255, 221, 178, 49),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: const Text('Create Account'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessRegisterScreen()));
                },
                child: const Text('Business Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
