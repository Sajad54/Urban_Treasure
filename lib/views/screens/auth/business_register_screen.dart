import 'package:flutter/material.dart';
import 'package:urban_treasure/controllers/auth_controller.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  State<BusinessRegisterScreen> createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<BusinessRegisterScreen> {
  // Getting auth controller
  final authController = AuthController();

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _emailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Register Button Pressed
  void register() async {
    final email = _emailController.text;
    final companyName = _companyNameController.text;
    final password = _passwordController.text;

    try {
      await authController.registerBusiness(email, companyName, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
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
                'Business Registration',
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
                  prefixIcon: Icon(
                    Icons.email,
                    color: Color.fromARGB(255, 221, 178, 49),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _companyNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter A Valid Company Name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Enter Company Name',
                  prefixIcon: Icon(
                    Icons.business,
                    color: Color.fromARGB(255, 221, 178, 49),
                  ),
                  border: OutlineInputBorder(),
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
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color.fromARGB(255, 221, 178, 49),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    register();
                  } else {
                    print('Not Valid');
                  }
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 75,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 221, 178, 49),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
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
