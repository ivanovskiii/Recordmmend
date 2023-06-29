import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recordmmend/model/shoppingcart.dart';
import 'package:recordmmend/model/shoppingcartitem.dart';
import 'package:recordmmend/model/vinyl.dart';

class ShoppingCartPage extends StatefulWidget {
  final String userId;

  ShoppingCartPage({required this.userId});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  List<Vinyl> vinyls = [];
  double cartTotal = 0.0; // Total price of items in the shopping cart

  @override
  void initState() {
    super.initState();
    fetchShoppingCartItems();
  }

  void removeFromCart(int index) async {
    final removedVinyl = vinyls.removeAt(index);

    final shoppingCartDoc = await FirebaseFirestore.instance
        .collection('shopping_cart')
        .doc(widget.userId)
        .get();

    if (shoppingCartDoc.exists) {
      final shoppingCart = ShoppingCart.fromSnapshot(shoppingCartDoc);
      final List<ShoppingCartItem> items = shoppingCart.items;

      // Find the ShoppingCartItem that corresponds to the removedVinyl
      final ShoppingCartItem removedItem = items.firstWhere(
        (item) => item.vinylId == removedVinyl.id,
        orElse: () => ShoppingCartItem(vinylId: '', quantity: 0),
      );

      if (removedItem != null) {
        items.remove(removedItem);

        await shoppingCartDoc.reference
            .update({'items': shoppingCart.toMap()['items']});
      }
    }

    setState(() {
      // Recalculate the cart total after removing an item
      cartTotal = vinyls.fold(0.0, (total, vinyl) => total + vinyl.price);
    });
  }

  Future<void> fetchShoppingCartItems() async {
    final shoppingCartDoc = await FirebaseFirestore.instance
        .collection('shopping_cart')
        .doc(widget.userId)
        .get();

    if (shoppingCartDoc.exists) {
      final shoppingCart = ShoppingCart.fromSnapshot(shoppingCartDoc);

      final List<ShoppingCartItem> items = shoppingCart.items;
      final List<String> vinylIds = items.map((item) => item.vinylId).toList();

      final vinylSnapshot = await FirebaseFirestore.instance
          .collection('vinyl')
          .where(FieldPath.documentId, whereIn: vinylIds)
          .get();

      final List<Vinyl> fetchedVinyls =
          vinylSnapshot.docs.map((doc) => Vinyl.fromSnapshot(doc)).toList();

      setState(() {
        vinyls = fetchedVinyls;

        // Calculate the cart total
        cartTotal = vinyls.fold(0.0, (total, vinyl) => total + vinyl.price);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: vinyls.length,
              itemBuilder: (context, index) {
                final vinyl = vinyls[index];

                return ListTile(
                  leading: Image.network(vinyl.albumCover),
                  title: Text(vinyl.albumName),
                  subtitle: Text('Price: \$${vinyl.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () => removeFromCart(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Cart Total: \$${cartTotal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement logic to proceed to checkout
            },
            child: Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }
}
