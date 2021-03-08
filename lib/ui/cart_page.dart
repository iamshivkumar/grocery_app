import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_app/core/futures/orders_list_future_provider.dart';
import 'package:grocery_app/core/models/cartProduct.dart';
import 'package:grocery_app/core/futures/product_future_provider.dart';
import 'package:grocery_app/core/view_models/address_view_model/address_view_model_provider.dart';
import 'package:grocery_app/core/view_models/auth_view_model/auth_view_model_provider.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model_provider.dart';
import 'package:grocery_app/ui/address_page.dart';
import 'package:grocery_app/ui/checkout_page.dart';
import 'package:grocery_app/ui/orders_page.dart';
import 'profile_page.dart';
import 'widgets/cart_product_card.dart';
import 'widgets/sign_in_sheet.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    ///accessing live state from [CartViewModel] by using [cartViewModelProvider] as [cartModel]
    var cartModel = watch(cartViewModelProvider);

    ///List of cart products
    List<CartProduct> cartProducts = [];

    ///total items in cart
    int items = 0;

    ///total price of cart products
    double price = 0;

    ///it gets cart products added by the user to use cart product id and quantity
    cartModel.cartProducts.forEach(
      (element) {
        ///it gets [Product] from the firestore by id by using [productFutureProvider]
        var productFuture = watch(productFutureProvider(element.id));
        productFuture.whenData(
          (value) {
            ///it decrements cart product quantity if store product not available with that much quantity
            int qt = value.quantity > element.qt ? element.qt : value.quantity;
            cartProducts.add(
              CartProduct.fromProduct(product: value, quantity: qt),
            );

            ///it counts total items in the cart
            items += qt;

            ///it calculates the total price of cart products
            price += value.price * qt;
          },
        );
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: Material(
          color: Colors.white,
          elevation: 8,
          child: ListTile(
            title: Row(
              children: [
                ///total items in cart
                Text(items.toString() + ' ' + 'Items'),
                Text(
                  ' | ',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
                ),

                ///total price of cart products
                Text('₹' + price.toString()),
              ],
            ),
            trailing: MaterialButton(
              onPressed: () async {
                ///it check internet connection is available or not
                bool connected = await DataConnectionChecker().hasConnection;

                ///if internet connection not available shows toast message as ["No Internet Connection"] and stop further process
                if (!connected) {
                  Fluttertoast.showToast(msg: "No Internet Connection");
                  return;
                }

                ///if any product out of stock it shows toast message to remove that product and stop further process
                if (cartProducts
                    .where((element) => element.stockQuantity == 0)
                    .isNotEmpty) {
                  Fluttertoast.showToast(msg: "Remove out of stock products");
                  return;
                }

                ///TODO: edit [100.0] (minimum value)
                ///if total price of cart products is less minimum value it shows toast meassage and stop further process
                if (price < 100.0) {
                  Fluttertoast.showToast(msg: "Minimum order value is ₹100");
                  return;
                }

                ///it access state from [AuthViewModel] by using [authViewModelProvider] as [authModel]

                if (context.read(authViewModelProvider).user == null) {
                  await SignInSheet(context).show();
                }
                var user = context.read(authViewModelProvider).user;
                if (user == null) {
                  return;
                }
                if (user.displayName == null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(),
                    ),
                  );
                }
                var addressModel = context.read(addressViewModelProvider);
                if (addressModel.locationAddressList.isEmpty) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressPage(),
                    ),
                  );
                }
                if (addressModel.locationAddressList.isEmpty) {
                  return;
                }
                cartModel.initializeForCheckout(
                    itemsValue: items,
                    priceValue: price,
                    products: cartProducts);
                bool ordered = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(),
                  ),
                );
                if (ordered != null && ordered) {
                  await context.refresh(ordersListFutureProvider);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrdersPage(),
                    ),
                  );
                }
              },
              color: Theme.of(context).accentColor,
              child: Text('CHECKOUT NOW'),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(2),
        children: cartProducts
            .map(
              (e) => CartProductCard(
                cartProduct: e,
              ),
            )
            .toList(),
      ),
    );
  }
}
