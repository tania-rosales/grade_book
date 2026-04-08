import 'package:flutter/material.dart';
import 'package:grade_book_tania/screens/login_screen.dart';

void main() {
  runApp(const GradeBookApp());
}

class GradeBookApp extends StatelessWidget {
  const GradeBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GradeBook",
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8), //Mi color primario
          brightness: Brightness.light 
        )
      ),
      home: LoginScreen()
    );
  }
}
