import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/components/button1.dart';
import 'package:parking/components/text_field1.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //kontroleri za textfield
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //funkcija za prijavljivanje korisnika
  void signUserIn() async {
    final buildContext = context;
    showDialog(
      context: buildContext,
      builder: (context) {
        return Center(
          child: LoadingAnimationWidget.waveDots(
            color: Colors.cyan,
            size: 50,
          ),
        );
      },
    );

    //pokusaj logovanja korisnika
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        wrongInputMessage(e.code);
      }
      return;
    }

    //uklanjanje ucitavanja
    if (mounted) {
      Navigator.pop(context);
    }
  }

  //funkcija za ispisivanje poruka o gresci
  void wrongInputMessage(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: Center(
              child: Text(message,
                  style: const TextStyle(
                    color: Colors.white,
                  )),
            ),
          );
        },
      );
    }
  }

  //metoda za resetovanje lozinke
  void resetPassword() async {
    if (emailController.text.isEmpty) {
      wrongInputMessage("Unesite vašu email adresu za resetovanje lozinke.");
      return;
    }

    final buildContext = context;

    showDialog(
      context: buildContext,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potvrda"),
          content:
              const Text("Da li ste sigurni da želite da resetujete lozinku?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(buildContext);
              },
              child: const Text("Odustani"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(buildContext);
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: emailController.text,
                  );

                  if (mounted) {
                    showDialog(
                      context: buildContext,
                      builder: (context) {
                        return const AlertDialog(
                          backgroundColor: Colors.green,
                          title: Center(
                            child: Text(
                              "Email za resetovanje lozinke je poslat.",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) {
                    wrongInputMessage(e.message ?? "Došlo je do greške.");
                  }
                }
              },
              child: const Text("Potvrdi"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  size: 100,
                  color: Color.fromRGBO(66, 66, 66, 1),
                ),
                const SizedBox(height: 50),
                Text(
                  'Dobrodošli nazad!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                //email
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                //lozinka
                MyTextField(
                  controller: passwordController,
                  hintText: 'Lozinka',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                //zaboravili ste lozinku
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: resetPassword,
                        child: Text(
                          'Zaboravili ste lozinku?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                //dugme za logovanje
                MyButton(
                  onTap: signUserIn,
                  text: "Prijavite se",
                ),
                const SizedBox(height: 50),
                //registruj se ako nemas nalog
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Niste član?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Registrujte se',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
