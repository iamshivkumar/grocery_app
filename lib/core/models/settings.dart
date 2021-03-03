import 'package:cloud_firestore/cloud_firestore.dart';

class StoreSettings {
  double serviceTaxPercentage;
  double deliveryCharge;
  final DocumentReference ref;
  StoreSettings({this.deliveryCharge, this.serviceTaxPercentage, this.ref});

  factory StoreSettings.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data();
    return StoreSettings(
        deliveryCharge: data["delivery"],
        serviceTaxPercentage: data["tax%"],
        ref: doc.reference);
  }
}
