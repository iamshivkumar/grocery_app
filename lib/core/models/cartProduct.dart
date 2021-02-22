import 'package:grocery_app/core/models/product.dart';

class CartProduct {
  final String id;
  final String name;
  final String image;
  final int stockQuantity;
  double price;
  String amount;
  int qt;
  CartProduct(
      {this.id,
      this.qt,
      this.image,
      this.name,
      this.price,
      this.amount,
      this.stockQuantity});

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
        id: json['id'],
        qt: json['qt'],
        image: json['image'],
        name: json['name'],
        price: json['price'],
        amount: json['amount']);
  }
  factory CartProduct.fromProduct({Product product, int quantity}) {
    return CartProduct(
      amount: product.amount,
      id: product.id,
      image: product.images.first,
      name: product.name,
      price: product.price,
      qt: quantity,
      stockQuantity: product.quantity,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qt': qt,
      'image': image,
      'name': name,
      'price': price,
      'amount': amount,
    };
  }

  void incrimentQt(int value) {
    qt = qt + value;
  }
}
