import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/introscreen_view_model/intro_screen_view_model.dart';

final introScreenViewModelProvider =
    ChangeNotifierProvider.autoDispose<IntroScreenViewModel>((ref) => IntroScreenViewModel());
