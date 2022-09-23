import 'package:biometric_attendance_system/form_screen/form_screen.dart';
import 'package:biometric_attendance_system/main_screen/main_screen.dart';
import 'package:biometric_attendance_system/profile_screen/profile_screen.dart';
import 'package:biometric_attendance_system/view_screen/view_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
    initHiveDB();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Attendance System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Colors.white,
        cardColor: Colors.white,
        cardTheme: const CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          elevation: 0,
          shadowColor: Colors.blue,
        ),
        primarySwatch: Colors.blue,
      ),

      //Initializing EasyLoading for better on screen notification
      builder: EasyLoading.init(),

      routes: {
        "/": (ctx) => getMainScreen(),
        MainScreen.routeName: (ctx) => const MainScreen(),
        FormScreen.routeName: (ctx) => const FormScreen(),
        ProfileScreen.routeName: (ctx) => const ProfileScreen(),
        ViewScreen.routeName: (ctx) => const ViewScreen(),
      },
    );
  }

  Widget getMainScreen() {
    // Show error message if initialization failed
    if (_error) {
      return const Center(
        child: Text("No Internet Connection"),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }

    return MainScreen();
  }

  void initHiveDB() async {
    //local Database name~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    await Hive.initFlutter();
    // var dir = await getApplicationDocumentsDirectory();
    // Hive.init(dir.path);
    await Hive.openBox('loginCredentials');
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }
}
