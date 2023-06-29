import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recordmmend/model/vinyl.dart';
import 'package:recordmmend/model/artist.dart';
import 'package:recordmmend/screens/homescreen.dart';
import 'package:recordmmend/screens/shoppingcartpage.dart';
import 'package:recordmmend/screens/signinscreen.dart';
import 'package:recordmmend/widgets/vinylcard.dart';
import 'package:geolocator/geolocator.dart';

class MainScreen extends StatefulWidget {
  final User? user;

  MainScreen({required this.user});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int cartItemCount = 0; // Number of items in the shopping cart
  String selectedGenre = 'All'; // Selected genre for sorting
  String searchQuery = ''; // Search query for filtering vinyls
  int _currentIndex =
      0; // Index of the current tab in the bottom navigation bar

  @override
  void initState() {
    super.initState();
    fetchCartItemCount();
  }

  Future<void> fetchCartItemCount() async {
    final shoppingCartCollection =
        FirebaseFirestore.instance.collection('shopping_cart');
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.uid;

      final shoppingCartDoc = await shoppingCartCollection.doc(userId).get();

      if (shoppingCartDoc.exists) {
        final shoppingCartData = shoppingCartDoc.data() as Map<String, dynamic>;

        setState(() {
          cartItemCount = shoppingCartData['vinyls'].length;
        });
      }
    }
  }

  void setGenre(String? genre) {
    setState(() {
      selectedGenre = genre ?? 'All';
    });
  }

  void setSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  List<Vinyl> sortVinylsByGenre(List<Vinyl> vinyls) {
    if (selectedGenre == 'All') {
      return vinyls;
    } else {
      return vinyls.where((vinyl) => vinyl.genre == selectedGenre).toList();
    }
  }

  List<Vinyl> filterVinylsBySearchQuery(List<Vinyl> vinyls) {
    if (searchQuery.isEmpty) {
      return vinyls;
    } else {
      final lowercaseQuery = searchQuery.toLowerCase();
      return vinyls.where((vinyl) {
        final lowercaseTitle = vinyl.albumName.toLowerCase();
        return lowercaseTitle.contains(lowercaseQuery);
      }).toList();
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      buildVinylList(),
      buildUserProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Recordmmend'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                cartItemCount > 0
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            cartItemCount.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShoppingCartPage(userId: widget.user!.uid),
                ),
              );
            },
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Vinyls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildVinylList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedGenre,
                onChanged: setGenre,
                items: <String>['All', 'rock', 'pop', 'indie', 'folk']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  onChanged: setSearchQuery,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('vinyl').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> vinylDocuments =
                      snapshot.data!.docs;
                  final List<Vinyl> vinyls = vinylDocuments
                      .map((doc) => Vinyl.fromSnapshot(doc))
                      .toList();
                  final List<Vinyl> sortedVinyls = sortVinylsByGenre(vinyls);
                  final List<Vinyl> filteredVinyls =
                      filterVinylsBySearchQuery(sortedVinyls);

                  return ListView.builder(
                    itemCount: filteredVinyls.length,
                    itemBuilder: (context, index) {
                      final vinyl = filteredVinyls[index];

                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('artist')
                            .doc(vinyl.artist)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final artistData =
                                snapshot.data!.data() as Map<String, dynamic>?;

                            if (artistData == null ||
                                artistData['artistName'] == null) {
                              return SizedBox();
                            }

                            final artistName =
                                artistData['artistName'] as String;

                            return VinylCard(
                              vinyl: vinyl,
                              artistName: artistName,
                            );
                          }
                          return SizedBox();
                        },
                      );
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data!;
                return Column(
                  children: [
                    Text(
                      'Hello, ${user.email}',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<Position>(
                      future: getCurrentPosition(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final position = snapshot.data!;
                          return Text(
                            'Location: ${position.latitude}, ${position.longitude}',
                            style: TextStyle(fontSize: 16),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            'Failed to retrieve location',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                );
              }
              return SizedBox();
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Future<Position> getCurrentPosition() async {
    LocationPermission permission;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    if (permission == LocationPermission.denied) {
      // Request location permissions if not granted
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Location permissions are denied.');
      }
    }

    // Retrieve the current position
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
