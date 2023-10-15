import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  final List items;
  final String formDescription;
  final String confirmationMessage;

  SignupScreen(
      {required this.items,
      required this.formDescription,
      required this.confirmationMessage,
      Key? key})
      : super(key: key);
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late String formTitle;
  late String formDescription;
  late String confirmationMessage;

  @override
  void initState() {
    super.initState();
    formTitle = '';
    formDescription = '';
    confirmationMessage = '';
    loadForm();
  }

  Future<void> loadForm() async {
    final String response = await rootBundle.loadString('assets/form.json');
    final data = json.decode(response);
    setState(() {
      formTitle = data['title'];
      formDescription = data['description'];
      confirmationMessage =
          data['presentation']['submission']['confirmation_message'];
    });
  }

  var _enteredFirstName = '';
  var _enteredLastName = '';
  var _enteredMiddleName = '';

  var _enteredUsername = '';
  var _enteredIIN = '';
  var _enteredPhone = '';

  final TextEditingController _enteredBirthday = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  Future<void> _submit() async {
    final isValid = _form.currentState?.validate() ?? false;

    if (isValid) {
      _form.currentState!.save();

      print(_enteredFirstName);
      print(_enteredLastName);
      print(_enteredMiddleName);
      print(_enteredUsername);
      print(_enteredIIN);
      print(_enteredPhone);
      print(_enteredBirthday.text);
      print(_password.text);
      print(confirmationMessage);

      Navigator.pop(context, confirmationMessage);
    }
  }

  TextInputType _getKeyboardType(int fieldId) {
    if (fieldId == 5 || fieldId == 6) {
      return TextInputType.number;
    } else {
      return TextInputType.name;
    }
  }

  List<Widget> _buildFormFields() {
    return widget.items.map<Widget>((item) {
      switch (item["type"]) {
        case "input_text":
          return Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: item["title"],
              ),
              keyboardType: _getKeyboardType(item["id"]),
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (item["is_required"] &&
                    (value == null || value.trim().isEmpty)) {
                  return item["errors"]["blank"];
                }

                if (item["id"] == 5) {
                  if (item["is_required"] &&
                      (value == null || value.trim().isEmpty)) {
                    return item["errors"]["blank"];
                  }
                  final RegExp iinRegex = RegExp(item["validators"]["regex"]);
                  if (!iinRegex.hasMatch(value!)) {
                    return item["errors"]["regex"];
                  }
                } else if (item["id"] == 6) {
                  if (item["is_required"] &&
                      (value == null || value.trim().isEmpty)) {
                    return item["errors"]["blank"];
                  }

                  final RegExp phoneRegex = RegExp(item["validators"]["regex"]);
                  if (!phoneRegex.hasMatch(value!)) {
                    return item["errors"]["regex"];
                  }
                }
                return null;
              },
              onSaved: (value) {
                switch (item["title"]) {
                  case "First name":
                    _enteredFirstName = value!;
                    break;
                  case "Last name":
                    _enteredLastName = value!;
                    break;
                  case "Middle name":
                    _enteredMiddleName = value!;
                    break;
                  case "Username":
                    _enteredUsername = value!;
                    break;
                  case "IIN":
                    _enteredIIN = value!;
                    break;
                  case "Phone number":
                    _enteredPhone = value!;
                    break;
                  default:
                    break;
                }
              },
            ),
          );
        case "date_selection":
          return Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: TextFormField(
              controller: _enteredBirthday,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: item["title"],
                suffixIcon: Icon(Icons.calendar_today_rounded),
              ),
              onTap: () async {
                DateTime? _pickedBirthday = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1980),
                  lastDate: DateTime.now(),
                );

                if (_pickedBirthday != null) {
                  setState(() {
                    _enteredBirthday.text =
                        DateFormat('yyyy-MM-dd').format(_pickedBirthday);
                  });
                }
              },
              keyboardType: TextInputType.datetime,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (item["is_required"] &&
                    (value == null || value.trim().isEmpty)) {
                  return item["errors"]["blank"];
                }
                return null;
              },
              onSaved: (value) {
                _enteredBirthday.text = value!;
              },
            ),
          );
        case "password":
          return Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: _password,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: item["title"],
              ),
              obscureText: true,
              validator: (value) {
                if (item["is_required"] &&
                    (value == null || value.trim().isEmpty)) {
                  return item["errors"]["blank"];
                }

                final RegExp passwordRegex =
                    RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,25}$');

                if (!passwordRegex.hasMatch(value!)) {
                  return item["errors"]["regex"];
                }

                return null;
              },
            ),
          );
        default:
          return Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: _confirmPass,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: item["title"],
              ),
              obscureText: true,
              validator: (value) {
                if (item["is_required"] &&
                    (value == null || value.trim().isEmpty)) {
                  return item["errors"]["blank"];
                }

                if (value != _password.text) {
                  return item["errors"]["target_value_mismatch"];
                }

                return null;
              },
            ),
          );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: Text(
                    widget.formDescription,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (widget.items.isNotEmpty)
                Center(
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: _buildFormFields(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 12, right: 20, left: 20),
                child: ElevatedButton(
                  onPressed: () {
                    _submit();
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
