import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/products_pagination_view_model/products_pagination_view_model.dart';

final productsViewModelProvider =
    ChangeNotifierProvider.family<ProductsViewModel,String>((ref,category) {
  return ProductsViewModel(category);
});
