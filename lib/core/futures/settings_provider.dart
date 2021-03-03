import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/settings.dart';

final settingsProvider = FutureProvider<StoreSettings>((ref) {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  return _firestore
      .collection('settings')
      .doc('settings')
      .get()
      .then((value) => StoreSettings.fromFirestore(value));
});
