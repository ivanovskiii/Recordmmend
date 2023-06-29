import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recordmmend/model/shoppingcartitem.dart';

class ShoppingCart {
  final String userId;
  final List<ShoppingCartItem> items;

  ShoppingCart({
    required this.userId,
    required this.items,
  });

  factory ShoppingCart.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final List<dynamic> itemsData = data['items'];

    final items = itemsData
        .map((itemData) => ShoppingCartItem.fromMap(itemData))
        .toList();

    return ShoppingCart(
      userId: data['userId'],
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    final List<Map<String, dynamic>> itemsData =
        items.map((item) => item.toMap()).toList();

    return {
      'userId': userId,
      'items': itemsData,
    };
  }
}
