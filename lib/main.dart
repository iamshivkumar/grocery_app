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
  TextTheme _buildShrineTextTheme(TextTheme base) {
    return base
        .copyWith(
          headline5: base.headline5.copyWith(
            fontWeight: FontWeight.w500,
          ),
          headline6: base.headline6.copyWith(fontSize: 18.0),
          caption: base.caption.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          bodyText1: base.bodyText1.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
        )
        .apply(
          displayColor: Colors.black,
          bodyColor: Colors.black,
          fontFamily: 'Rubik',
        );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var init = watch(initializer);
    final Color accentColor = Color(0xFF4E598C);
    var base = ThemeData.light();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        textTheme: _buildShrineTextTheme(base.textTheme),
        primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
        accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
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
