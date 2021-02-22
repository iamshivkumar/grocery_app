import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/product.dart';

final productFutureProvider =
    FutureProvider.autoDispose.family<Product, String>(
  (ref, id) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    ref.maintainState = true;
    return _firestore
        .collection('products')
        .doc(id)
        .get()
        .then((value) => Product.fromFirestore(doc: value));
  },
);
