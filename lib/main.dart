import 'package:flutter/material.dart';
import 'pages/Entry Credentials/welcome.dart';
import 'pages/Entry Credentials/Login/login.dart';

void main() {
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
