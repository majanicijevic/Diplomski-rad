import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/data/parking_data.dart';
import 'package:parking/pages/parking_page.dart';
import 'package:parking/pages/profile_page.dart';
import 'package:parking/pages/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Sve lokacije';

  final user = FirebaseAuth.instance.currentUser!;

  //funkcija koja se poziva kada korisnik zeli da promeni stranu u donjoj navigacijskoj traci
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //funkcija koja je poziva kada korisnik odabere filter
  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredParkingData = parkingData;
    if (_selectedFilter == 'Električno punjenje') {
      filteredParkingData = parkingData
          .where((parking) => parking['chargerSpot'] == true)
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _onFilterSelected('Sve lokacije'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: _selectedFilter == 'Sve lokacije'
                              ? Colors.white
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: _selectedFilter == 'Sve lokacije'
                              ? [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          'Sve lokacije',
                          style: TextStyle(
                            color: _selectedFilter == 'Sve lokacije'
                                ? Colors.grey[800]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onFilterSelected('Električno punjenje'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: _selectedFilter == 'Električno punjenje'
                              ? Colors.white
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: _selectedFilter == 'Električno punjenje'
                              ? [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          'Električno punjenje',
                          style: TextStyle(
                            color: _selectedFilter == 'Električno punjenje'
                                ? Colors.grey[800]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredParkingData.length,
                  itemBuilder: (context, index) {
                    final parking = filteredParkingData[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParkingPage(parking: parking),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        height: 150,
                        child: Card(
                          color: Colors.grey[350],
                          elevation: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Image.asset(
                                  parking['image']!,
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        parking['name']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(66, 66, 66, 1),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text('${parking['location']}',
                                          overflow: TextOverflow.ellipsis),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (parking['parkingSpot'])
                                            const Icon(
                                              Icons.local_parking_rounded,
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                            ),
                                          if (parking['chargerSpot'])
                                            const Icon(
                                              Icons.ev_station,
                                              color: Color.fromRGBO(
                                                  158, 158, 158, 1),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          //poziv ekrana za pretragu kroz pocetnu stranu
          const SearchPage(),
          //poziv ekrana sa informacijama o profilu kroz pocetnu stranu
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Početna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pretraga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.grey[800],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(color: Colors.grey[800]),
        unselectedLabelStyle: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}
