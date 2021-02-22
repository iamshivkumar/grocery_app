import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model.dart';


final cartViewModelProvider =
    ChangeNotifierProvider<CartViewModel>(
  (ref) {
    return CartViewModel();
  },
);
