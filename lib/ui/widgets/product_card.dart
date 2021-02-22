import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/models/product.dart';
import 'package:grocery_app/core/view_models/cart_view_model/cart_view_model_provider.dart';
import 'package:grocery_app/ui/product_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  ProductCard({@required this.product});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductPage(product: product),
        ),
      ),
      child: Material(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  ///first image of product
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(product.images.first),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ///product name
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            product.name,
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              ///price of product
                              Text(
                                '₹' + product.price.toString() + " / ",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor),
                              ),
                              //amount of product
                              Text(
                                product.amount,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0.5,
            ),
            GestureDetector(
              onTap: () {},
              child: SizedBox(
                height: 40,

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
                              ? TextButton(
                                  onPressed: () =>
                                      cartModel.addToCart(product: product),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart_outlined),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text('Add to Cart'),
                                    ],
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      /// it decrement cart product quantity by one
                                      onPressed: () =>
                                          cartModel.updateCartQuantity(
                                              price: product.price,
                                              id: product.id,
                                              qt: -1),
                                      child: Icon(Icons.remove_circle_outline),
                                    ),

                                    ///quantity of cart product added
                                    Text(
                                      cartModel.cartProducts
                                          .where((e) => e.id == product.id)
                                          .first
                                          .qt
                                          .toString(),
                                    ),
                                    TextButton(
                                      /// it icrement cart product quantity by one if store product quantity more than that
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
                                      child: Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                );
                        },
                      )
                    : Center(
                        child: Text(
                          'Out Of Stock',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
