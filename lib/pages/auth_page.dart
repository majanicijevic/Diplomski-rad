import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/pages/home_page.dart';
import 'package:parking/pages/login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //ako je ulogovan korisnik
            if (snapshot.hasData) {
              return const HomePage();
            }
            //ako nije ulogovan korisnik
            else {
              return const LoginOrRegisterPage();
            }
          }),
    );
  }
}
