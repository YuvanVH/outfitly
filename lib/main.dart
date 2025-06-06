import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'themes/light_mode.dart';
import 'themes/dark_mode.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Kontrollera om --use-emulators finns som argument
    bool useEmulators = args.contains('--use-emulators');
    if (useEmulators) {
      FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
      FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
      debugPrint(
        'Using Firebase Emulators: Auth(9099), Firestore(8080), Storage(9199)',
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    runApp(ErrorApp(error: 'Failed to initialize Firebase: $e'));
    return;
  }
  runApp(const MyApp());
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(bool) toggleTheme;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) =>
      themeMode != oldWidget.themeMode;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _maintenance = false;

  @override
  void initState() {
    super.initState();
    _checkMaintenance();
    _loadTheme();
  }

  Future<void> _checkMaintenance() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('config')
            .doc('status')
            .get();
    if (doc.exists && doc.data()?['maintenance'] == true) {
      setState(() {
        _maintenance = true;
      });
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('themeMode') ?? 'system';
    if (mounted) {
      setState(() {
        _themeMode = switch (theme) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };
      });
    }
  }

  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', isDark ? 'dark' : 'light');
    if (mounted) {
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_maintenance) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Appen är tillfälligt stängd pga budgetgräns. Försök igen senare.',
              style: TextStyle(fontSize: 20, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return ThemeProvider(
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        themeMode: _themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
