import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        final currentUser = Supabase.instance.client.auth.currentUser;

        if (currentUser != null) {
          final insertResponse = await Supabase.instance.client
              .from('profiles')
              .insert({
                'id': currentUser.id,
                'username': username,
                'email': email,
                'role': 'user',
              })
              .select()
              .single();

          if (insertResponse != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Registration Successful")),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to insert user profile")),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sign up failed — no user returned")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Register Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _usernameController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a username' : null,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 221, 178, 49)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a valid email' : null,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 221, 178, 49)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmEmailController,
                validator: (value) =>
                    value != _emailController.text ? 'Emails do not match' : null,
                decoration: const InputDecoration(
                  labelText: 'Confirm Email',
                  hintText: 'Re-enter Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined, color: Color.fromARGB(255, 221, 178, 49)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a password' : null,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 221, 178, 49)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) =>
                    value != _passwordController.text ? 'Passwords do not match' : null,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline, color: Color.fromARGB(255, 221, 178, 49)),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _isLoading ? null : _register,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 75,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 221, 178, 49),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Already Have An Account?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
