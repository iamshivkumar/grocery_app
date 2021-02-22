import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'address_view_model.dart';

final addressViewModelProvider = ChangeNotifierProvider<AddressViewModel>(
  (ref) => AddressViewModel(),
);
