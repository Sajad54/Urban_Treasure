/*
Listens for auth state changes 

----------------------------------------------------
unauthenticated -> Login Page
authenticated -> Profile Page

*/ 

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/auth/login_screen.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';

class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listens to auth state changes 
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      builder: (context, snapshot) {
        // Loading Circle
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(),)
          );
        }
        // Checks if there is a valid session currently 
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null){
          return const HomeScreen() ;
        } 
        else {
          return const LoginScreen();
        }
        }
      );
      }
      
  }
