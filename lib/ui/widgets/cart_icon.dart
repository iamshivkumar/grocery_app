import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model_provider.dart';
import '../cart_page.dart';

class CartIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var cartModel = watch(cartViewModelProvider);
    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.shopping_cart_outlined),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.black45,
              child: Text(
                cartModel.cartProducts.length.toString(),
                style: Theme.of(context).textTheme.overline.copyWith(
                  color: Colors.white
                ),
              ),
            ),
          )
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(),
          ),
        );
      },
    );
  }
}
