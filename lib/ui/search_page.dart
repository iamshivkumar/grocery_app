import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/futures/search_keys_provider.dart';
import 'package:grocery_app/core/view_models/search_view_model/search_view_model_provider.dart';
import 'widgets/product_card.dart';

class ProductSearch extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          showSuggestions(context);
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final productsModel = watch(
          searchViewModelProvider(query.toLowerCase()),
        );
        return Builder(
          builder: (context) {
            ///if products are empty
            if (productsModel.products.isEmpty) {
              ///it get 6 products from Firestore
              productsModel.getProducts();

              ///show [CircularProgressIndicator] if products are empty
              if (productsModel.circleLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (productsModel.products.isEmpty)
                return Center(
                  child: Text("No Products Available"),
                );
            }

            ///if products are not empty
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                ///it get 2 more products when max scrolled down (Pagination)

                if (!productsModel.busy &&
                    notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent) {
                  productsModel.getProductsMore();
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  ///it refresh products / reget products from firestore
                  context.refresh(
                    searchViewModelProvider(query.toLowerCase()),
                  );
                },
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(8),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildListDelegate(
                          productsModel.products
                              .map(
                                (e) => ProductCard(product: e),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                    ///shows [CircularProgressIndicator] at bottom when 2 more products loading
                    SliverToBoxAdapter(
                      child: Center(
                        child: productsModel.loading &&
                                productsModel.products.length > 5
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              )
                            : SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        var keysAsync = watch(searchKeysProvder);
        return keysAsync.when(
          data: (keys) {
            final suggestionList = query.isEmpty
                ? []
                : keys
                    .where((element) =>
                        element.toLowerCase().startsWith(query.toLowerCase()))
                    .toList();
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  query = suggestionList[index];
                  showResults(context);
                },
                title: RichText(
                  text: TextSpan(
                    text: suggestionList[index].substring(0, query.length),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: suggestionList[index].substring(query.length),
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              itemCount: suggestionList.length,
            );
          },
          loading: () => CircularProgressIndicator(),
          error: (error, stackTrace) => Text(error.toString()),
        );
      },
    );
  }
}
