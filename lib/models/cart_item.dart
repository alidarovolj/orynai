import 'product.dart';

class CartItem {
  final int id;
  final String userPhone;
  final int productId;
  final int quantity;
  final String addedAt;
  final String deliveryDestinationAddress;
  final String deliveryArrivalTime;
  final int deliveryMethodId;
  final Product product;

  CartItem({
    required this.id,
    required this.userPhone,
    required this.productId,
    required this.quantity,
    required this.addedAt,
    required this.deliveryDestinationAddress,
    required this.deliveryArrivalTime,
    required this.deliveryMethodId,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      userPhone: json['user_phone'] as String,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      addedAt: json['added_at'] as String,
      deliveryDestinationAddress: json['delivery_destination_address'] as String,
      deliveryArrivalTime: json['delivery_arrival_time'] as String,
      deliveryMethodId: json['delivery_method_id'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_phone': userPhone,
      'product_id': productId,
      'quantity': quantity,
      'added_at': addedAt,
      'delivery_destination_address': deliveryDestinationAddress,
      'delivery_arrival_time': deliveryArrivalTime,
      'delivery_method_id': deliveryMethodId,
      'product': product.toJson(),
    };
  }

  int get totalPrice => product.price * quantity;
}
