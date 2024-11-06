import 'package:flutter/material.dart';
import 'package:parking/components/search_text_field.dart';
import 'package:parking/data/parking_data.dart';
import 'package:parking/pages/parking_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //filtriranje podataka
    final filteredParkingData = parkingData.where((parking) {
      final nameMatches =
          parking['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final locationMatches = parking['location']!
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return nameMatches || locationMatches;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                SearchTextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Rezultati pretrage:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(66, 66, 66, 1),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          color:
                                              Color.fromRGBO(158, 158, 158, 1),
                                        ),
                                      if (parking['chargerSpot'])
                                        const Icon(
                                          Icons.ev_station,
                                          color:
                                              Color.fromRGBO(158, 158, 158, 1),
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
    );
  }
}
