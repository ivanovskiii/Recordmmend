class ShoppingCartItem {
  final String vinylId;
  late final int quantity;

  ShoppingCartItem({
    required this.vinylId,
    required this.quantity,
  });

  factory ShoppingCartItem.fromMap(Map<String, dynamic> map) {
    return ShoppingCartItem(
      vinylId: map['vinylId'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vinylId': vinylId,
      'quantity': quantity,
    };
  }
}
