import 'package:flutter/material.dart';
import 'package:registration_app/screens/home.dart';

class MyApp extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  MyApp(this.items);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 89, 24, 141),
        ),
      ),
      home: HomeScreen(items),
    );
  }
}

void main() {
  List<Map<String, dynamic>> items = [];

  runApp(MyApp(items));
}
