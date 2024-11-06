import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking/components/button1.dart';
import 'package:parking/components/text_field1.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});
  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _isLoading = false;

  void _updatePassword() async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword != confirmNewPassword) {
      _showErrorDialog('Lozinke se ne poklapaju');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        //ponovno prijavljivanje korisnika kako bi se ažurirale njegove akreditivnosti
        await user.reauthenticateWithCredential(credential);

        //ažuriranje lozinke
        await user.updatePassword(newPassword);

        _showSuccessDialog('Lozinka uspešno promenjena');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Došlo je do greške');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //funkcija za prikazivanje poruka o gresci
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Greška'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK',
                  style: TextStyle(
                    color: Colors.grey[800],
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //funkcija za prikazivanje poruke o uspehu
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Uspešno'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK',
                  style: TextStyle(
                    color: Colors.grey[800],
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'lib/images/logo.png',
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'ParkSpot',
              style: TextStyle(
                color: Color.fromRGBO(66, 66, 66, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Color.fromRGBO(66, 66, 66, 1),
                ),

                const SizedBox(height: 50),

                //tekst
                Text(
                  'Promenite lozinku',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                //trenutna lozinka
                MyTextField(
                  controller: _currentPasswordController,
                  hintText: 'Trenutna lozinka',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //nova lozinka
                MyTextField(
                  controller: _newPasswordController,
                  hintText: 'Nova lozinka',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //potvrdi novu lozinku
                MyTextField(
                  controller: _confirmNewPasswordController,
                  hintText: 'Potvrdi novu lozinku',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                //dugme za promenu lozinke
                MyButton(
                  onTap: _updatePassword,
                  text: 'Promeni lozinku',
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
      //prikazi indikator učitavanja dok se čeka na promenu lozinke
      floatingActionButton: _isLoading
          ? FloatingActionButton(
              backgroundColor: Colors.grey[700],
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
              onPressed: () {},
            )
          : null,
    );
  }
}
