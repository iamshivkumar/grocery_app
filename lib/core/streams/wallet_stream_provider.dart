import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/wallet.dart';

final walletStreamProvider = StreamProvider<Wallet>(
  (ref) {
    User _user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore
        .collection('wallets')
        .doc(_user.uid)
        .snapshots()
        .map((event) => Wallet.fromFirestore(event));
  },
);
