// lib/main.dart

import 'package:flutter/material.dart';
import 'package:myapp/Screen/HomePage.dart';
// import 'home_page.dart'; // Import the HomePage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attainment AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(), // Set the HomePage as the home
    );
  }
}
