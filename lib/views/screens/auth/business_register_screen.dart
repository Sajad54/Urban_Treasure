import 'package:flutter/material.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';

class RegisterScreen2 extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                'Business Registration',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(
                height: 25,),
              TextFormField(
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
                 validator: (value) {
                  if(value!.isEmpty) {
                    return 'Please Enter A Valid Company Name';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Enter Company Name',
                  prefixIcon: Icon(
                    Icons.business,
                    color: const Color.fromARGB(255, 221, 178, 49),
                    ),
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
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
                    print('Valid');
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