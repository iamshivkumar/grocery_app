import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:grocery_app/core/models/product.dart';

class ProductsViewModel extends ChangeNotifier {
  final String category;
  ProductsViewModel(this.category);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _snapshots = [];
  QuerySnapshot value;
  List<Product> get products =>
      _snapshots.map((e) => Product.fromFirestore(doc: e)).toList();
  Future<void> getProducts() async {

    _snapshots = await _firestore
        .collection("products")
        .where("active",isEqualTo: true)
        .where(category == "Popular" ? "popular" : "category",
            isEqualTo: category == "Popular" ? true : category)
        .orderBy("name")
        .limit(6)
        .get()
        .then((value) => value.docs);
    notifyListeners();
  }

  bool loading = true;
  bool busy = false;
  Future<void> getProductsMore() async {
    busy = true;
    var previous = _snapshots;
    try {
      _snapshots = _snapshots +
          await _firestore
              .collection("products")
              .where("active",isEqualTo: true)
              .where(category == "Popular" ? "popular" : "category",
                  isEqualTo: category == "Popular" ? true : category)
              .orderBy("name")
              .startAfterDocument(_snapshots.last)
              .limit(4)
              .get()
              .then((value) {
            return value.docs;
          });
      print(_snapshots.length);
      if (_snapshots.length == previous.length) {
        loading = false;
      } else {
        loading = true;
      }
    } catch (e) {
      print(e.toString());
    }
    busy = false;
    notifyListeners();
  }
}
