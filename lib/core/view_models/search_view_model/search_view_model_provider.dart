import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_view_model.dart';

final searchViewModelProvider =
    ChangeNotifierProvider.family<SearchViewModel, String>(
  (ref, key) {
    return SearchViewModel(key);
  },
);
