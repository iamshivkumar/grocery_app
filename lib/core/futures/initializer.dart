import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_app/core/view_models/address_view_model/address_view_model_provider.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final initializer = FutureProvider<bool>((ref) async {
  DataConnectionChecker().hasConnection.then((value) {
    if (!value) {
      Fluttertoast.showToast(msg: "No Internet Connection");
    }
  });
  ref.read(cartViewModelProvider).initializeData();
  ref.read(addressViewModelProvider).initializeData();
  bool seen = await SharedPreferences.getInstance().then(
    (value) => value.getBool("seen"),
  );
  return seen == null ? false : seen;
});
