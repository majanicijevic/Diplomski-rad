import 'package:flutter/material.dart';
import 'package:parking/components/button1.dart';
import 'package:parking/pages/booking_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingPage extends StatelessWidget {
  final Map<String, dynamic> parking;

  const ParkingPage({super.key, required this.parking});

  //funkcija za kreiranje kolekcije parkingSpots
  Future<void> createParkingSpotInFirestore() async {
    CollectionReference parkingSpots =
        FirebaseFirestore.instance.collection('parkingSpots');

    //kreiranje dokumenta ako već ne postoji
    DocumentSnapshot doc = await parkingSpots.doc(parking['parkingId']).get();
    if (!doc.exists) {
      await parkingSpots.doc(parking['parkingId']).set({
        'parkingID': parking['parkingId'],
        'pspots': parking['pspots'],
        'cspots': parking['cspots'],
      });
    }
  }

  //funkcija za preuzimanje podataka o parking mestima
  Future<Map<String, dynamic>?> getParkingSpotFromFirestore() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('parkingSpots')
        .doc(parking['parkingId'])
        .get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    createParkingSpotInFirestore();

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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getParkingSpotFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
            ));
          }
          if (!snapshot.hasData) {
            return const Center(
                child:
                    Text('Podaci nisu pronađeni, probaj da osvežiš stranicu.'));
          }

          final parkingSpotData = snapshot.data!;
          final pspots = parkingSpotData['pspots'];
          final cspots = parkingSpotData['cspots'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(parking['image']!,
                    width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    parking['name']!,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.cyan,
                      ),
                      const SizedBox(width: 5),
                      Text('${parking['location']}, Kragujevac'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Broj slobodnih parking mesta: ',
                        style: TextStyle(
                          color: Color.fromRGBO(66, 66, 66, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('$pspots'),
                    ],
                  ),
                ),
                if (parking['chargerSpot'])
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Broj slobodnih mesta za punjenje: ',
                          style: TextStyle(
                            color: Color.fromRGBO(66, 66, 66, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('$cspots'),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  child: Row(
                    children: [
                      if (parking['parkingSpot'])
                        const Icon(
                          Icons.local_parking_rounded,
                          color: Colors.cyan,
                        ),
                      if (parking['chargerSpot'])
                        const Icon(
                          Icons.ev_station,
                          color: Colors.cyan,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Opis: ',
                        style: TextStyle(
                            color: Color.fromRGBO(66, 66, 66, 1),
                            fontWeight: FontWeight.bold),
                      ),
                      Flexible(
                        child: Text(parking['description']!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: MyButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BookingPage(parking: parking)),
                      );
                    },
                    text: 'REZERVIŠI SADA',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
