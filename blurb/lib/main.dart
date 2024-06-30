// libraries
import 'dart:async';

import 'package:blurb/screens/introduction.dart';
import 'package:blurb/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// screens
import 'package:blurb/screens/search.dart';

// utility
import 'package:blurb/utility/database.dart';

void main() {
  // Ensure that Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const App());
}

TextStyle breeSerif() =>
    GoogleFonts.breeSerif().copyWith(color: const Color(0xFF4E4637));

// theme
final theme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4E4637),
    primary: const Color(0xFFF1E5D1),
    secondary: const Color(0xFFCBEEE4),
    tertiary: const Color(0xFFDBCFBC),
    onPrimary: const Color(0xFF4E4637),
    onSecondary: const Color(0xFF4E4637),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF4E4637),
    selectionHandleColor: Color(0xFF8EB7B0),
    selectionColor: Color(0xFFC3FCF2),
  ),
  scaffoldBackgroundColor: const Color(0xFFF1E5D1),
  textTheme: GoogleFonts.openSansTextTheme().copyWith(
    headlineLarge: breeSerif(),
    titleLarge: breeSerif(),
    titleMedium: breeSerif(),
    titleSmall: breeSerif(),
    bodyMedium: breeSerif(),
    headlineSmall: breeSerif(),
    labelLarge: GoogleFonts.notoSerif(),
  ),
);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Future<Database> database;

  @override
  void initState() {
    super.initState();
    database = DictionaryDatabase.instance.database;
  }

  @override
  void dispose() {
    super.dispose();
    database.then((db) => db.close());
  }

  @override
  Widget build(context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'blurb.',
        theme: theme,
        home: FutureBuilder(
          future: database,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            return const HelperWidget();
          },
        ));
  }
}

class HelperWidget extends StatefulWidget {
  const HelperWidget({super.key});

  @override
  State<HelperWidget> createState() => _HelperWidgetState();
}

class _HelperWidgetState extends State<HelperWidget> {
  late Future<bool> seenIntro;

  @override
  void initState() {
    super.initState();
    seenIntro = hasSeenIntroduction();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> hasSeenIntroduction() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool('seenIntro') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: seenIntro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        final bool introSeen = snapshot.data ?? false;
        return introSeen ? const SearchScreen() : const IntroScreen();
      },
    );
  }
}
