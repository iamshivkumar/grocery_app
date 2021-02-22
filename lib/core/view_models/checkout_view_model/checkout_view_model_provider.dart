import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/address_view_model/address_view_model_provider.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model_provider.dart';
import 'package:grocery_app/core/view_models/checkout_view_model/checkout_view_model.dart';

final checkoutViewModelProvider =
    ChangeNotifierProvider.autoDispose<CheckoutViewModel>((ref) {
  var cartModel = ref.read(cartViewModelProvider);
  var addressList = ref.read(addressViewModelProvider).locationAddressList;
  return CheckoutViewModel(
      cartProducts: cartModel.cartProducts,
      locationAddressList: addressList,
      items: cartModel.items,
      price: cartModel.price);
});
