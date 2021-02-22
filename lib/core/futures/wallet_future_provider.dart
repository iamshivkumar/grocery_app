import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/wallet.dart';

final walletFutureProvider = FutureProvider.autoDispose<Wallet>(
  (ref) {
    User _user = FirebaseAuth.instance.currentUser;
    ref.maintainState = true;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore.collection('wallets').doc(_user.uid).get().then(
          (value) => Wallet.fromFirestore(value),
        );
  },
);
