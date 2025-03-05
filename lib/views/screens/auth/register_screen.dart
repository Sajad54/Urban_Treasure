import 'package:flutter/material.dart';
import 'package:urban_treasure/controllers/auth_controller.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';

class RegisterScreen extends StatelessWidget{
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String email;
  late String fullName;
  late String passWord;
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
                Text(
                  'Register Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(
                  height: 25,),
                TextFormField(
                  onChanged: (value){
                    email = value;
                  },
                  validator: (value) {
                    if(value!.isEmpty) {
                      return 'Please Enter A Valid Email Address';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Example@gmail.com',
                    prefixIcon: Icon(
                      Icons.email,
                      color: const Color.fromARGB(255, 221, 178, 49),
                      ),
                      border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onChanged: (value) {
                    fullName = value;
                  },
                   validator: (value) {
                    if(value!.isEmpty) {
                      return 'Please Enter A Valid Name';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter Full Name',
                    prefixIcon: Icon(
                      Icons.person,
                      color: const Color.fromARGB(255, 221, 178, 49),
                      ),
                    border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onChanged: (value) {
                    passWord = value;
                  },
                   validator: (value) {
                    if(value!.isEmpty) {
                      return 'Please Enter A Valid Password';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter Password',
                    prefixIcon: Icon(
                      Icons.lock,
                      color: const Color.fromARGB(255, 221, 178, 49),
                      ),
                    border: OutlineInputBorder()
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: (){
                    if(_formKey.currentState!.validate()) {
                      _authController.createNewUser(email, fullName, passWord);
                      print('Success');
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
                    child: Center(
                        child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                TextButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }));
                }, child: Text('Already Have An Account?',),
                ),
              ],
            ),
          ),
        ),
      );
  }
}