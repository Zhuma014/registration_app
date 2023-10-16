import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  List items = [];
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  String formTitle = '';
  String formDescription = '';
  String confirmationMessage = '';

  @override
  void initState() {
    super.initState();
    loadFormFields();
  }

  Future<void> loadFormFields() async {
    final String response1 = await rootBundle.loadString('assets/form.json');
    final form = json.decode(response1);
    final String response2 = await rootBundle.loadString('assets/fields.json');
    final fields = await json.decode(response2);
    setState(() {
      formTitle = form['title'];
      formDescription = form['description'];
      confirmationMessage =
          form['presentation']['submission']['confirmation_message'];
      items = fields;
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

  List<Widget> _buildFormFields() {
    Widget buildTextFormField(Map<String, dynamic> item) {
      return TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: item["title"],
        ),
        keyboardType: TextInputType.name,
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        validator: (value) {
          if (item["is_required"] && (value == null || value.trim().isEmpty)) {
            return item["errors"]["blank"];
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
            default:
              break;
          }
        },
      );
    }

    Widget buildNumberFormField(Map<String, dynamic> item) {
      return TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: item["title"],
        ),
        keyboardType: TextInputType.number,
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        validator: (value) {
          if (item["is_required"] && (value == null || value.trim().isEmpty)) {
            return item["errors"]["blank"];
          }

          if (item["title"] == "IIN") {
            final RegExp iinRegex = RegExp(item["validators"]["regex"]);
            if (!iinRegex.hasMatch(value!)) {
              return item["errors"]["regex"];
            }
          } else if (item["title"] == "Phone number") {
            final RegExp phoneRegex = RegExp(item["validators"]["regex"]);
            if (!phoneRegex.hasMatch(value!)) {
              return item["errors"]["regex"];
            }
          }
          return null;
        },
        onSaved: (value) {
          switch (item["title"]) {
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
      );
    }

    Widget buildDateSelectionField(Map<String, dynamic> item) {
      return TextFormField(
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
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        validator: (value) {
          if (item["is_required"] && (value == null || value.trim().isEmpty)) {
            return item["errors"]["blank"];
          }
          return null;
        },
        onSaved: (value) {
          _enteredBirthday.text = value!;
        },
      );
    }

    Widget buildPasswordField(Map<String, dynamic> item) {
      return TextFormField(
        controller: _password,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: item["title"],
        ),
        keyboardType: TextInputType.text,
        obscureText: true,
        validator: (value) {
          if (item["is_required"] && (value == null || value.trim().isEmpty)) {
            return item["errors"]["blank"];
          }

          final RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,25}$');

          if (!passwordRegex.hasMatch(value!)) {
            return item["errors"]["regex"];
          }

          return null;
        },
      );
    }

    Widget buildConfirmPasswordField(Map<String, dynamic> item) {
      return TextFormField(
        controller: _confirmPass,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: item["title"],
        ),
        keyboardType: TextInputType.text,
        obscureText: true,
        validator: (value) {
          if (item["is_required"] && (value == null || value.trim().isEmpty)) {
            return item["errors"]["blank"];
          }

          if (value != _password.text) {
            return item["errors"]["target_value_mismatch"];
          }

          return null;
        },
      );
    }

    return items.map<Widget>((item) {
      Widget buildForm;

      switch (item["type"]) {
        case "input_text":
          buildForm = buildTextFormField(item);
          break;
        case "input_number":
          buildForm = buildNumberFormField(item);
          break;
        case "date_selection":
          buildForm = buildDateSelectionField(item);
          break;
        case "password":
          buildForm = buildPasswordField(item);
          break;
        case "password_confirmation":
          buildForm = buildConfirmPasswordField(item);
          break;
        default:
          buildForm = buildTextFormField(item);
          break;
      }

      return Padding(
        padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
        child: buildForm,
      );
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
                    formDescription,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (items.isNotEmpty)
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
