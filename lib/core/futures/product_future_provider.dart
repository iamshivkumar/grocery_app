import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/product.dart';

final productFutureProvider =
    FutureProvider.family<Product, String>(
  (ref, id) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore
        .collection('products')
        .doc(id)
        .get()
        .then((value) => Product.fromFirestore(doc: value));
  },
);
