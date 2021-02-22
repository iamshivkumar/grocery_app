import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String amount;
  final String description;
  final List<dynamic> images;
  final bool active;
  final bool popular;

  Product({
    this.description,
    this.id,
    this.images,
    this.name,
    this.price,
    this.amount,
    this.quantity,
    this.active,
    this.popular,
    this.category,
  });

  factory Product.fromFirestore({DocumentSnapshot doc}) {
    Map data = doc.data();
    return Product(
        id: doc.id,
        name: data['name'],
        price: data['price'],
        description: data['description'],
        images: data['images'],
        amount: data['amount'],
        quantity: data['quantity'],
        active: data['active'],
        category: data['category'],
        popular: data['popular']);
  }
}
