import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    _companyNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerBusiness() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final companyName = _companyNameController.text.trim();
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
              'username': companyName,
              'email': email,
              'role': 'vendor',
            })
            .select()
            .single();

        if (insertResponse != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Business Registered Successfully")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
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
                'Business Registration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _companyNameController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a valid company name' : null,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Enter Company Name',
                  prefixIcon: Icon(Icons.business, color: Color.fromARGB(255, 221, 178, 49)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a valid email address' : null,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'example@gmail.com',
                  prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 221, 178, 49)),
                  border: OutlineInputBorder(),
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
                  prefixIcon: Icon(Icons.email_outlined, color: Color.fromARGB(255, 221, 178, 49)),
                  border: OutlineInputBorder(),
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
                  prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 221, 178, 49)),
                  border: OutlineInputBorder(),
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
                  prefixIcon: Icon(Icons.lock_outline, color: Color.fromARGB(255, 221, 178, 49)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _registerBusiness();
                        } else {
                          debugPrint('Form not valid');
                        }
                      },
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
              const SizedBox(height: 6),
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
