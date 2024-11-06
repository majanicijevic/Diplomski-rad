import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking/components/button1.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> parking;

  const BookingPage({super.key, required this.parking});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool isParkingSpotSelected = true; // po defaultu parking mesto je selektovano

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  //funkcija za selektovanje datuma
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2024),
        lastDate: DateTime(2025));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  //funkcija za selektovanje vremena
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  //funkcija za kreiranje rezervacija
  Future<void> createBooking() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Korisnik nije prijavljen");
      }

      Map<String, dynamic> bookingInfo = {
        "userID": user.uid,
        "parkingID": widget.parking['parkingId'],
        "parkingName": widget.parking['name'],
        "location": widget.parking['location'],
        "date":
            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
        "time":
            "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
        "type": isParkingSpotSelected
            ? "parking mesto"
            : "mesto za punjenje automobila",
      };

      await FirebaseFirestore.instance.collection('bookings').add(bookingInfo);

      //ažuriranje slobodnih mesta u kolekciji parkingSpots
      String parkingID = widget.parking['parkingId'];
      DocumentReference parkingSpotRef =
          FirebaseFirestore.instance.collection('parkingSpots').doc(parkingID);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(parkingSpotRef);

        if (!snapshot.exists) {
          throw Exception("Parking mesto ne postoji.");
        }

        int currentSpots;
        if (isParkingSpotSelected) {
          currentSpots = snapshot.get('pspots');
          if (currentSpots <= 0) {
            throw Exception("Nema slobodnih parking mesta.");
          }
          transaction.update(parkingSpotRef, {'pspots': currentSpots - 1});
        } else {
          currentSpots = snapshot.get('cspots');
          if (currentSpots <= 0) {
            throw Exception("Nema slobodnih mesta za punjenje.");
          }
          transaction.update(parkingSpotRef, {'cspots': currentSpots - 1});
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Rezervacija je uspešna!'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Greška prilikom rezervacije: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Rezervacija za parking:',
                style: TextStyle(
                  color: Color.fromRGBO(66, 66, 66, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Text(
                widget.parking['name']!,
                style: const TextStyle(
                  color: Color.fromRGBO(66, 66, 66, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.cyan,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (widget.parking['chargerSpot']) ...[
              RadioListTile<bool>(
                title: const Text('parking mesto'),
                value: true,
                groupValue: isParkingSpotSelected,
                onChanged: (bool? value) {
                  setState(() {
                    isParkingSpotSelected = value!;
                  });
                },
              ),
              RadioListTile<bool>(
                title: const Text('mesto za punjenje automobila'),
                value: false,
                groupValue: isParkingSpotSelected,
                onChanged: (bool? value) {
                  setState(() {
                    isParkingSpotSelected = value!;
                  });
                },
              ),
            ] else ...[
              RadioListTile<bool>(
                title: const Text('parking mesto'),
                value: true,
                groupValue: isParkingSpotSelected,
                onChanged: null,
              ),
            ],
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: Container(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(30)),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    const Text(
                      "Izaberi datum",
                      style: TextStyle(
                          color: Color.fromRGBO(66, 66, 66, 1),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 25,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _selectTime(context);
              },
              child: Container(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(30)),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    const Text(
                      "Izaberi vreme",
                      style: TextStyle(
                          color: Color.fromRGBO(66, 66, 66, 1),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.alarm,
                          color: Colors.white,
                          size: 25,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: MyButton(
                onTap: () async {
                  await createBooking();
                },
                text: 'Konačna rezervacija',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
