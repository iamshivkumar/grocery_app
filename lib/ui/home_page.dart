import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/products_pagination_view_model/products_pagination_view_model_provider.dart';
import 'package:grocery_app/ui/widgets/cart_icon.dart';
import 'package:grocery_app/ui/widgets/custom_drawer.dart';
import 'package:grocery_app/ui/widgets/product_card.dart';
import 'cart_page.dart';

class HomePage extends StatelessWidget {
  ///TODO: edit categories as per your store grocery products
  final List<String> categories = [
    'Popular',
    'Fruits',
    "Vegetables",
    'Food',
    'Drinks',
    'Snacks'
  ];
  @override
  Widget build(BuildContext context) {
    return CustomDrawer(
      child: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => CustomDrawer.of(context).open(),
                );
              },
            ),

            ///TODO: edit title (app / store name)
            title: Text('Grocery App'),
            centerTitle: true,
            actions: [
              CartIcon()
            ],
            bottom: TabBar(
              tabs: categories
                  .map(
                    (e) => Tab(
                      text: e,
                    ),
                  )
                  .toList(),
              isScrollable: true,
            ),
          ),
          body: TabBarView(
            children:
                categories.map((e) => ProductListView(category: e)).toList(),
          ),
        ),
      ),
    );
  }
}

class ProductListView extends ConsumerWidget {
  final String category;
  ProductListView({@required this.category});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    ///accessing live state from [ProductsViewModel] using [productsViewModelProvider] for specific category as [productsModel]
    final productsModel = watch(productsViewModelProvider(category));
    return Builder(
      builder: (context) {
        ///if products are empty
        if (productsModel.products.isEmpty) {
          ///it get 6 products from Firestore
          productsModel.getProducts();

          ///show [CircularProgressIndicator] if products are empty
          return Center(child: CircularProgressIndicator());
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
              context.refresh(productsViewModelProvider(category));
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
  }
}
