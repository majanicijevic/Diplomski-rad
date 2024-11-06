import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/components/button1.dart';
import 'package:parking/components/text_field1.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parking/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //kontroleri za textfield
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  //funkcija za registrovanje korisnika
  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: LoadingAnimationWidget.waveDots(
            color: Colors.cyan,
            size: 50,
          ),
        );
      },
    );

    //pokušaj registrovanja korisnika
    try {
      if (passwordController.text == confirmpasswordController.text) {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        String uid = userCredential.user!.uid;

        //kreiranje mape sa informacijama o korisniku
        Map<String, dynamic> userInfoMap = {
          "name": nameController.text,
          "email": emailController.text,
          "uid": uid,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(userInfoMap);

        //uklanjanje učitavanja
        if (mounted) {
          Navigator.pop(context);

          //preusmeravanje na ekran za prijavu
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginPage(
                      onTap: null,
                    )),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          wrongInputMessage("Lozinke se ne poklapaju");
        }
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        wrongInputMessage(e.code);
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  //funkcija za ispisivanje poruka o gresci
  void wrongInputMessage(String message) {
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
                  Icons.person_add,
                  size: 100,
                  color: Color.fromRGBO(66, 66, 66, 1),
                ),

                const SizedBox(height: 50),

                Text(
                  'Dobrodošli!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                //ime
                MyTextField(
                  controller: nameController,
                  hintText: 'Ime',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //email
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //unesi lozinku
                MyTextField(
                  controller: passwordController,
                  hintText: 'Lozinka',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //potvrdi lozinku
                MyTextField(
                  controller: confirmpasswordController,
                  hintText: 'Potvrda lozinke',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                //dugme za logovanje
                MyButton(
                  onTap: signUserUp,
                  text: "Registrujte se",
                ),

                const SizedBox(height: 50),

                //registruj se ako nemas nalog
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Već imate nalog?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Prijavite se',
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
