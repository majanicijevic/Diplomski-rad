import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/components/list_tile1.dart';
import 'package:parking/pages/reserved_page.dart';
import 'package:parking/pages/update_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //funkcija za odjavljivanje korisnika
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  String name = '';
  String email = '';
  bool isLoading = true;
  String errorMessage = '';

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  //funkcija za preuzimanje podataka o korisniku
  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            name = userDoc.data()?['name'] ?? 'N/A';
            email = userDoc.data()?['email'] ?? 'N/A';
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'User data not found.';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error fetching user data: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'No user currently logged in.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Tvoj Profil',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const Image(
                            image: AssetImage('lib/images/person.jpg'))),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(user.email!),
                      ],
                    ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              MyListTile(
                icon: Icons.book_outlined,
                text: 'Rezervisana parkiranja',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReservedPage()),
                  );
                },
              ),
              MyListTile(
                icon: Icons.edit,
                text: 'Promeni lozinku',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpdatePage()),
                  );
                },
              ),
              MyListTile(
                icon: Icons.logout,
                text: 'Odjavi se',
                onTap: signUserOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
