import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:carousel_slider/carousel_slider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage()
    );
  }
}

