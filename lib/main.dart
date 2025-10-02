import 'package:flutter/material.dart';
import 'pages/Entry Credentials/welcome.dart';
import 'pages/Entry Credentials/Login/login.dart';
import 'routes/local_storage.dart';
import 'routes/user_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.instance.load();
  await UserPrefs.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
       routes: {
         '/login': (_) =>  LoginPage(),
       },
    );
  }
}
