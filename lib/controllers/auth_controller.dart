import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password 
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Create new user and save to database
  Future<AuthResponse?> createNewUser(String email, String password, String fullName) async {
    try {
      // Sign up the user
      final response = await _supabase.auth.signUp(email: email, password: password);
      
      if (response.user != null) {
        // Insert user details into the database
        await _supabase.from('users').insert({
          'id': response.user!.id, // Use the generated Supabase user ID
          'email': email,
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
        });

        return response;
      }
    } catch (e) {
      print('Error creating new user: $e');
    }

    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user email
  String? getCurrentEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
