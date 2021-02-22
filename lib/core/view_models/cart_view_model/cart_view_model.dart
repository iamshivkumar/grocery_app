import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:grocery_app/core/models/cartProduct.dart';
import 'package:grocery_app/core/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartViewModel extends ChangeNotifier {
  List<CartProduct> _cartProducts = [];
  List<CartProduct> get cartProducts => _cartProducts;
  double price;
  int items;
  Future initializeData() async {
    try {
      await readCartProducts();
    } catch (e) {
      saveCartProducts();
    }
    notifyListeners();
  }

  void addToCart({Product product}) async {
    _cartProducts.add(
      CartProduct(
        id: product.id,
        qt: 1,
        image: product.images.first,
        name: product.name,
        amount: product.amount,
        price: product.price,
      ),
    );
    saveCartProducts();
    notifyListeners();
  }

  void updateCartQuantity({String id, int qt, double price}) async {
    var cartProduct = _cartProducts.where((element) => element.id == id).first;
    if (cartProduct.qt == 1 && qt == -1) {
      _cartProducts.remove(cartProduct);
    } else {
      cartProduct.incrimentQt(qt);
    }
    saveCartProducts();
    notifyListeners();
  }

  void removeFromCart({String id, double price, int qt}) async {
    _cartProducts.removeWhere((element) => element.id == id);
    saveCartProducts();
    notifyListeners();
  }

  void makeCartEmpty() {
    _cartProducts = [];
    notifyListeners();
    saveCartProducts();
  }

  Future<void> readCartProducts() async {
    _cartProducts = [];
    final prefs = await SharedPreferences.getInstance();
    prefs.getStringList("cartProducts").forEach((element) {
      _cartProducts.add(CartProduct.fromJson(json.decode(element)));
    });
  }

  void saveCartProducts() async {
    List<String> list = [];
    final prefs = await SharedPreferences.getInstance();
    cartProducts.forEach((element) {
      list.add(json.encode(element.toJson()));
    });
    prefs.setStringList("cartProducts", list);
  }

  void initializeForCheckout(
      {double priceValue, int itemsValue, List<CartProduct> products}) {
    price = priceValue;
    items = itemsValue;
    _cartProducts = products;
    saveCartProducts();
  }
}
