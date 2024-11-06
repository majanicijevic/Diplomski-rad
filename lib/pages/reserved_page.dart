import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking/components/button3.dart';

class ReservedPage extends StatefulWidget {
  const ReservedPage({super.key});

  @override
  State<ReservedPage> createState() => _ReservedPageState();
}

class _ReservedPageState extends State<ReservedPage> {
  //funkcija za otkazivanje rezervacije
  Future<void> cancelBooking(String bookingId) async {
    final buildContext = context;

    showDialog(
      context: buildContext,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potvrda"),
          content: const Text(
              "Da li ste sigurni da želite da otkažete ovu rezervaciju?"),
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
                  //preuzimanje informacija o rezervaciji pre nego što se obriše dokument
                  DocumentSnapshot bookingSnapshot = await FirebaseFirestore
                      .instance
                      .collection('bookings')
                      .doc(bookingId)
                      .get();

                  if (bookingSnapshot.exists) {
                    String parkingID = bookingSnapshot['parkingID'];
                    String type = bookingSnapshot['type'];

                    //ažuriranje slobodnih mesta u parkingSpots kolekciji
                    DocumentReference parkingSpotRef = FirebaseFirestore
                        .instance
                        .collection('parkingSpots')
                        .doc(parkingID);

                    FirebaseFirestore.instance
                        .runTransaction((transaction) async {
                      DocumentSnapshot snapshot =
                          await transaction.get(parkingSpotRef);

                      if (!snapshot.exists) {
                        throw Exception("Parking mesto ne postoji.");
                      }

                      if (type == "parking mesto") {
                        int currentPSpots = snapshot.get('pspots');
                        transaction.update(
                            parkingSpotRef, {'pspots': currentPSpots + 1});
                      } else if (type == "mesto za punjenje automobila") {
                        int currentCSpots = snapshot.get('cspots');
                        transaction.update(
                            parkingSpotRef, {'cspots': currentCSpots + 1});
                      }
                    });

                    // Otkazivanje rezervacije
                    await FirebaseFirestore.instance
                        .collection('bookings')
                        .doc(bookingId)
                        .delete();

                    if (mounted) {
                      setState(() {
                        ScaffoldMessenger.of(buildContext).showSnackBar(
                          const SnackBar(
                            content: Text('Rezervacija je otkazana.'),
                          ),
                        );
                      });
                    }
                  }
                } catch (e) {
                  print('Greška prilikom otkazivanja rezervacije: $e');
                }
              },
              child: const Text("Potvrdi"),
            ),
          ],
        );
      },
    );
  }

  //funkcija za brisanje isteklih rezervacija
  Future<void> deleteExpiredBookings() async {
    try {
      DateTime now = DateTime.now();

      QuerySnapshot bookingsSnapshot =
          await FirebaseFirestore.instance.collection('bookings').get();

      for (QueryDocumentSnapshot doc in bookingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<String> dateParts = (data['date'] as String).split('/');
        List<String> timeParts = (data['time'] as String).split(':');
        DateTime bookingDateTime = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        if (now.isAfter(bookingDateTime)) {
          //ažuriranje slobodnih mesta pre nego što se obriše dokument
          String parkingID = data['parkingID'];
          String type = data['type'];

          DocumentReference parkingSpotRef = FirebaseFirestore.instance
              .collection('parkingSpots')
              .doc(parkingID);

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentSnapshot snapshot = await transaction.get(parkingSpotRef);

            if (!snapshot.exists) {
              throw Exception("Parking mesto ne postoji.");
            }

            if (type == "parking mesto") {
              int currentPSpots = snapshot.get('pspots');
              transaction.update(parkingSpotRef, {'pspots': currentPSpots + 1});
            } else if (type == "mesto za punjenje automobila") {
              int currentCSpots = snapshot.get('cspots');
              transaction.update(parkingSpotRef, {'cspots': currentCSpots + 1});
            }
          });

          //brisanje rezervacije
          await doc.reference.delete();
        }
      }
    } catch (e) {
      //korisnik ne treba da vidi greske
    }
  }

  @override
  void initState() {
    super.initState();
    deleteExpiredBookings();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
      body: user == null
          ? const Center(
              child: Text(
                'Morate biti prijavljeni da biste videli svoje rezervacije.',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tvoje rezervacije:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(66, 66, 66, 1),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('userID', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.cyan),
                        ));
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('Došlo je do greške.'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('Nemate rezervacija.'));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var booking = snapshot.data!.docs[index];

                          return Card(
                            color: Colors.grey[300],
                            elevation: 0,
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(
                                booking['parkingName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(66, 66, 66, 1)),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lokacija: ${booking['location']}'),
                                  Text('Datum: ${booking['date']}'),
                                  Text('Vreme: ${booking['time']}'),
                                  Text('Tip: ${booking['type']}'),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: MyButton3(
                                      onTap: () async {
                                        await cancelBooking(booking.id);
                                      },
                                      text: 'Otkaži rezervaciju',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
