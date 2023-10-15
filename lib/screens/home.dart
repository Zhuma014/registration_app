import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sign_up.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(List<Map<String, dynamic>> items);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _items = [];
  String formDescription = '';
  String confirmationMessage = '';

  Future<void> readFields() async {
    final String response = await rootBundle.loadString('assets/fields.json');

    final data = await json.decode(response);

    setState(() {
      _items = data;
    });
  }

  Future<void> readForm() async {
    final String response = await rootBundle.loadString('assets/form.json');
    final data = json.decode(response);
    setState(() {
      formDescription = data['description'];
    });
  }

  @override
  void initState() {
    super.initState();
    readForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 20, bottom: 20, right: 20, left: 20),
          child: ElevatedButton(
            onPressed: () async {
              BuildContext currentContext = context;

              readFields().then((_) async {
                final result = await Navigator.push(
                  currentContext,
                  MaterialPageRoute(
                    builder: (context) => SignupScreen(
                      items: _items,
                      formDescription: formDescription,
                      confirmationMessage: confirmationMessage,
                    ),
                  ),
                );

                if (result != null) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(result)));
                }
              });
            },
            child: Text('Sign Up'),
          ),
        ),
      ),
    );
  }
}
