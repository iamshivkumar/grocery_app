import 'package:cloud_firestore/cloud_firestore.dart';

class Wallet {
  final double amount;
  final bool refundRequested;

  Wallet({this.amount, this.refundRequested});

  factory Wallet.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data();
    return Wallet(
      amount: data["amount"],
      refundRequested: data["refundRequested"],
    );
  }
}
