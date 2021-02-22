import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';

final authViewModelProvider =
    ChangeNotifierProvider.autoDispose<AuthViewModel>((ref) => AuthViewModel());
