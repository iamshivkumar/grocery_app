import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/cartProduct.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model_provider.dart';

class CartProductCard extends ConsumerWidget {
  final CartProduct cartProduct;
  CartProductCard({this.cartProduct});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final cartModel = context.read(cartViewModelProvider);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Dismissible(
        direction: DismissDirection.startToEnd,
        background: Container(
          color: Theme.of(context).primaryColorDark,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 24,
                child: Icon(
                  Icons.delete_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        key: Key(cartProduct.id),
        onDismissed: (direction) => cartModel.removeFromCart(
          id: cartProduct.id,
          qt: cartProduct.qt,
          price: cartProduct.price,
        ),
        child: AspectRatio(
          aspectRatio: 3,
          child: Material(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.network(cartProduct.image),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 8, right: 8, bottom: 4),
                        child: Text(
                          cartProduct.name,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 4, left: 8, right: 8, bottom: 8),
                        child: Text(
                          cartProduct.amount,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '₹' + cartProduct.price.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: cartProduct.stockQuantity != 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              splashRadius: 24,
                              color: Theme.of(context).accentColor,
                              splashColor: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.2),
                              highlightColor: Colors.transparent,
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () => cartModel.updateCartQuantity(
                                  price: cartProduct.price,
                                  id: cartProduct.id,
                                  qt: -1),
                            ),
                            Text(
                              cartProduct.qt.toString(),
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            IconButton(
                              splashRadius: 24,
                              color: Theme.of(context).accentColor,
                              splashColor: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.2),
                              highlightColor: Colors.transparent,
                              icon: Icon(Icons.add_circle_outline),
                              onPressed:
                                  cartProduct.stockQuantity > cartProduct.qt
                                      ? () => cartModel.updateCartQuantity(
                                          price: cartProduct.price,
                                          id: cartProduct.id,
                                          qt: 1)
                                      : null,
                            ),
                          ],
                        )
                      : Center(
                          child: Text("Out Of Stock"),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
