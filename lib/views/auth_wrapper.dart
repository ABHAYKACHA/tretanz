import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'login_view.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if a user is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginView(); // Navigate to Login if no user
          } else {
            return const HomeScreen(); // Navigate to Home if user exists
          }
        }

        // Show a loading indicator while checking auth state
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}