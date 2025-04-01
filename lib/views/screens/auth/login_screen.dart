import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/main.dart';
import 'package:urban_treasure/views/screens/auth/register_screen.dart';
import 'package:urban_treasure/views/screens/auth/business_register_screen.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';
import 'package:urban_treasure/views/screens/auth/OtpVerificationScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

        // Case: Login successful without MFA
        if (result.session != null) {
          final userId = result.user?.id;
          final profile = await supabase
              .from('profiles')
              .select()
              .eq('id', userId!)
              .maybeSingle();

          if (profile == null) {
            await supabase.auth.signOut();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No profile found. Please register again.")),
            );
            return;
          }

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );

        // Case: MFA challenge required
        } else if (result.session == null && result.user != null) {
          final factors = await supabase.auth.mfa.listFactors();

          final emailFactor = factors.all.firstWhere(
            (f) => f.factorType == 'email_otp',
            orElse: () => throw Exception("No email MFA factor found."),
          );

          final factorId = emailFactor.id;

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(factorId: factorId),
            ),
          );
        } else {
          throw Exception('Unexpected login state.');
        }
      } on AuthApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An Error Occurred: ${e.message}')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error occurred: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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
              const Text(
                'Account Login',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter A Valid Email Address';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Example@gmail.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Color.fromARGB(255, 221, 178, 49),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter A Valid Password';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color.fromARGB(255, 221, 178, 49),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width - 75, 50),
                  backgroundColor: const Color.fromARGB(255, 221, 178, 49),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  );
                },
                child: const Text('Create Account'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BusinessRegisterScreen()),
                  );
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
