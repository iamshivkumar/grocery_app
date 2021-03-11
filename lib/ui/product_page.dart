import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/product.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model_provider.dart';
import 'package:grocery_app/ui/widgets/cart_icon.dart';
import 'package:grocery_app/ui/widgets/product_image_viewer.dart';

class ProductPage extends StatelessWidget {
  final Product product;
  ProductPage({this.product});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        actions: [
          CartIcon()
        ],
        title: Text(product.name),
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: Material(
          color: Colors.white,
          elevation: 8,

          ///if product available in store shows Buttons to Add products or edit quanity else shos out of stock
          child: product.quantity > 0
              ? Consumer(
                  builder: (context, watch, child) {
                    ///accessing live state from [CartViewModel] by using [cartViewModelProvider] as [cartModel]
                    var cartModel = watch(cartViewModelProvider);

                    ///if product not in cart shows add to cart button else shows quantity increment-decriment buttons
                    return cartModel.cartProducts
                            .where((e) => e.id == product.id)
                            .isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            child: MaterialButton(
                              onPressed: () =>
                                  cartModel.addToCart(product: product),
                              color: Theme.of(context).accentColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_cart_outlined),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text('ADD TO CART'),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Text(
                                    '\$' +
                                        (cartModel.cartProducts
                                                    .where((e) =>
                                                        e.id == product.id)
                                                    .first
                                                    .qt *
                                                product.price)
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      color: Theme.of(context).accentColor,
                                      splashColor: Theme.of(context)
                                          .accentColor
                                          .withOpacity(0.2),
                                      highlightColor: Colors.transparent,
                                      icon: Icon(Icons.remove_circle_outline),
                                      onPressed: () =>
                                          cartModel.updateCartQuantity(
                                              price: product.price,
                                              id: product.id,
                                              qt: -1),
                                      iconSize: 32,
                                    ),
                                    Text(
                                      cartModel.cartProducts
                                          .where((e) => e.id == product.id)
                                          .first
                                          .qt
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                      ),
                                    ),
                                    IconButton(
                                      color: Theme.of(context).accentColor,
                                      splashColor: Theme.of(context)
                                          .accentColor
                                          .withOpacity(0.2),
                                      highlightColor: Colors.transparent,
                                      icon: Icon(Icons.add_circle_outline),
                                      onPressed: product.quantity >
                                              cartModel.cartProducts
                                                  .where(
                                                      (e) => e.id == product.id)
                                                  .first
                                                  .qt
                                          ? () => cartModel.updateCartQuantity(
                                              price: product.price,
                                              id: product.id,
                                              qt: 1)
                                          : null,
                                      iconSize: 32,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                  },
                )
              : Center(
                  child: Text(
                    "Out Of Stock",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
        ),
      ),
      body: ListView(
        children: [
          ///Product images widget
          Material(
            color: Colors.white,
            child: AspectRatio(
              aspectRatio: 1,
              child: ProductImageViewer(
                images: product.images,
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: [
                ///price of product
                Text(
                  '₹' + product.price.toString() + " /",
                  style: TextStyle(
                      fontSize: 24, color: Theme.of(context).primaryColor),
                ),

                ///amount of product
                Text(
                  product.amount,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),

          ///name of product
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              product.name,
              style: TextStyle(fontSize: 24),
            ),
          ),

          ///category of product
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              product.category,
              style: Theme.of(context).textTheme.caption,
            ),
          ),

          ///description of product
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(product.description),
          )
        ],
      ),
    );
  }
}
