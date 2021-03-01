import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/futures/initializer.dart';
import 'package:grocery_app/ui/home_page.dart';
import 'package:grocery_app/ui/intro_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ///initialize [Firebase] services
  await Firebase.initializeApp();
  runApp(
    /// All Flutter applications using Riverpod must contain a [ProviderScope] at the root of their widget tree
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var init = watch(initializer);
    final Color accentColor = Color(0xFF4E598C);
    return MaterialApp(
      color: Colors.white,
      title: 'Grocery',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFEF6EC),
        primaryColor: Color(0xFFFCAF58),
        primaryColorDark: Color(0xFFFF8C42),
        primaryColorLight: Color(0xFFFDEDD8),
        backgroundColor: Colors.white,
        accentColor: accentColor,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: accentColor,
            shape: RoundedRectangleBorder(),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: accentColor),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          buttonColor: accentColor,
          textTheme: ButtonTextTheme.primary,
        ),
      ),

      ///if user app already seen shows [HomePage] else [IntroScreen] (Onboarding Screen)

      home: init.when(
        data: (seen) => seen ? HomePage() : IntroScreen(),
        loading: () => Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Container(
          color: Colors.white,
        ),
      ),
    );
  }
}
