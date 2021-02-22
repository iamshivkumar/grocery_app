import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/order.dart';

final ordersListFutureProvider = FutureProvider.autoDispose<List<Order>>(
  (ref) {
    User user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    ref.maintainState = true;
   
    return _firestore
        .collection('orders')
        .where("customerId", isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get()
        .then(
          (value) => value.docs
              .map(
                (e) => Order.fromFirestore(doc: e),
              )
              .toList(),
        );
  },
);
