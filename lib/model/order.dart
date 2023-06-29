import 'package:recordmmend/model/vinyl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;
  final String shoppingCartId;
  final List<Vinyl> vinyls;
  final double totalPrice;
  final DateTime orderDate;

  Order({
    required this.orderId,
    required this.shoppingCartId,
    required this.vinyls,
    required this.totalPrice,
    required this.orderDate,
  });
}
