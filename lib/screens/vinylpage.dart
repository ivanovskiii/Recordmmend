import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recordmmend/model/vinyl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recordmmend/screens/artistpage.dart';
import 'package:recordmmend/model/shoppingcart.dart';

import '../model/shoppingcartitem.dart';

class VinylPage extends StatefulWidget {
  final Vinyl vinyl;

  VinylPage({required this.vinyl});

  @override
  _VinylPageState createState() => _VinylPageState();
}

class _VinylPageState extends State<VinylPage> {
  int quantity = 1; // Initial quantity
  String artistName = '';
  String artistId = '';

  @override
  void initState() {
    super.initState();
    fetchArtistData();
  }

  Future<void> fetchArtistData() async {
    final artistDoc = await FirebaseFirestore.instance
        .collection('artist')
        .doc(widget.vinyl.artist)
        .get();
    final artistData = artistDoc.data();
    if (artistData != null && artistData['artistName'] != null) {
      setState(() {
        artistName = artistData['artistName'];
        artistId = artistDoc.id;
      });
    }
  }

  void navigateToArtistPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistPage(artistId: artistId),
      ),
    );
  }

  Future<void> addToCart(Vinyl vinyl, int quantity) async {
    final shoppingCartCollection =
        FirebaseFirestore.instance.collection('shopping_cart');
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.uid;

      final shoppingCartDoc = await shoppingCartCollection.doc(userId).get();

      if (shoppingCartDoc.exists) {
        // Shopping cart already exists for the user, update the existing cart
        final shoppingCart = ShoppingCart.fromSnapshot(shoppingCartDoc);
        final existingItemIndex =
            shoppingCart.items.indexWhere((item) => item.vinylId == vinyl.id);

        if (existingItemIndex != -1) {
          // Vinyl already exists in the shopping cart, update the quantity
          final existingItem = shoppingCart.items[existingItemIndex];
          final updatedQuantity = existingItem.quantity + quantity;
          shoppingCart.items[existingItemIndex] =
              ShoppingCartItem(vinylId: vinyl.id, quantity: updatedQuantity);
        } else {
          // Vinyl doesn't exist in the shopping cart, add a new item
          shoppingCart.items
              .add(ShoppingCartItem(vinylId: vinyl.id, quantity: quantity));
        }

        await shoppingCartCollection.doc(userId).set(shoppingCart.toMap());
      } else {
        // Shopping cart doesn't exist for the user, create a new cart
        final shoppingCart = ShoppingCart(userId: userId, items: [
          ShoppingCartItem(vinylId: vinyl.id, quantity: quantity),
        ]);

        await shoppingCartCollection.doc(userId).set(shoppingCart.toMap());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vinyl.albumName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 350.0, // Adjust the width to make the image smaller
                height: 350.0, // Adjust the height to make the image smaller
                child: Image.network(widget.vinyl.albumCover),
              ),
              SizedBox(height: 16.0),
              Text(
                widget.vinyl.albumName,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: navigateToArtistPage,
                child: Text(
                  '$artistName',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                'Price: \$${widget.vinyl.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                'Genre: ${widget.vinyl.genre}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) {
                          quantity--;
                        }
                      });
                    },
                  ),
                  Text(
                    quantity.toString(),
                    style: TextStyle(fontSize: 16.0),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  addToCart(widget.vinyl, quantity);
                },
                child: Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
