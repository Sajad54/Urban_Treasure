import "package:flutter/material.dart";
import "package:urban_treasure/controllers/auth_controller.dart";
import 'package:urban_treasure/views/screens/auth/register_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  // Getting auth controller
  final authController = AuthController();

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Login Button Pressed
  void login() async {
    // Preparing data
    final email = _emailController.text;
    final password = _passwordController.text;

    // Try-Catch for login attempt
    try {
      await authController.signInWithEmailPassword(email, password);
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
              InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    login();
                  } else {
                    print('Unable To Login');
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
                      'Login',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/* 

From Firebase Build 

*/


// import 'package:flutter/material.dart';
// import 'package:urban_treasure/views/screens/auth/register_screen.dart';
// import 'package:urban_treasure/views/screens/auth/business_register_screen.dart';

// class LoginScreen extends StatelessWidget {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late String email;
//   late String passWord;
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Padding(
//           padding: const EdgeInsets.only(bottom: 60, left: 14, right: 14),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center, 
//               children: [
//                 Text(
//                   'Account Login',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 4,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 25,),
//                 TextFormField(
//                   onChanged: (value){
//                     email = value;
//                   },
//                   validator: (value) {
//                     if(value!.isEmpty) {
//                       return 'Please Enter A Valid Email Address';
//                     } else {
//                       return null;
//                     }
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Email Address',
//                     hintText: 'Example@gmail.com',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(
//                       Icons.email,
//                       color: const Color.fromARGB(255, 221, 178, 49),
//                       ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 TextFormField(
//                   onChanged: (value){
//                     passWord = value;
//                   },
//                   validator: (value) {
//                     if(value!.isEmpty) {
//                       return 'Please Enter A Valid Password';
//                     } else {
//                       return null;
//                     }
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     hintText: 'Enter Password',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(
//                       Icons.lock,
//                       color: const Color.fromARGB(255, 221, 178, 49),
//                       ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 InkWell(
//                   onTap: (){
//                     if(_formKey.currentState!.validate()){
//                       print(email);
//                       print(passWord);
//                     } else {
//                       print('Unable To Login');
//                     }
//                   },
//                   child: Container(
//                     height: 50,
//                     width: MediaQuery.of(context).size.width - 75,
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 221, 178, 49),
//                       borderRadius: BorderRadius.circular(25),
                      
//                     ),
//                     child: Center(
//                         child: Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         letterSpacing: 4,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     )),
//                   ),
//                 ),
//                TextButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context){
//                     return RegisterScreen();
//                   } ));
//                 }, 
//                 child: Text('Create Account',)
//                 ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context){
//                     return RegisterScreen2();
//                   } ));
//                 }, 
//                 child: Text('Business Registration ',)
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//   }
// }
