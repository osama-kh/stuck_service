import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../models/main_theme.dart';
import '../models/worngDialgo.dart';

class change_password extends StatefulWidget {
  String field;
  var field_data;
  var dataOfUser;

  change_password(this.field, this.field_data, this.dataOfUser);

  @override
  State<change_password> createState() => _change_passwordState();
}

class _change_passwordState extends State<change_password> {
  String password = '';
  RegExp pass_valid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  bool password_conf = true;
  String field_t = "";
  String password_confermation = "";
  bool old_obscure = true;
  bool new_obscure = true;
  bool confirm_obscure = true;
  bool password_checker = false;
  bool confirm = false;
  final _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final _firestore = FirebaseFirestore.instance;

  //A function that validate user entered password
  bool validatePassword(String pass) {
    String _password = pass.trim();
    if (pass_valid.hasMatch(_password)) {
      return true;
    } else {
      return false;
    }
  }

  var oldValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_theme().get_white(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: main_theme().get_blue_grey()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.field,
            style: TextStyle(color: main_theme().get_blue_grey())),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context, widget.dataOfUser);
            }),
        actions: [
          Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () async {
                if (confirm == true) {
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: widget.dataOfUser['Email'], password: oldValue);

                    if (user != null) {
                      User? currentuser = _auth.currentUser;

                      currentuser?.updatePassword(password_confermation);

                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => worngDialgo(
                              text: 'Password updated successfully.'));
                    }
                  } catch (e) {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => worngDialgo(
                            text: 'the current password not correct.'));
                    print(e);
                  }
                } else {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) =>
                          worngDialgo(text: 'Enter a correct password'));
                }
              },
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                  primary: main_theme().get_blue_grey()),
            ),
          )
        ],
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(left: 3, right: 3),
              color: Colors.black12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 50,
                  ),

                  Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Current password",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Container(
                    child: TextFormField(
                      obscureText: old_obscure,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              old_obscure = !old_obscure;
                            });
                          },
                          child: Icon(old_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(0, 0, 0, 0),
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: main_theme().get_blue_grey(),
                          ),

                          //<-- SEE HERE
                        ),
                      ),
                      onChanged: (value) {
                        oldValue = value;
                        if (value == '') {}
                      },
                    ),
                  ),

                  //////
                  Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "New password",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Container(
                    child: TextFormField(
                      obscureText: new_obscure,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              new_obscure = !new_obscure;
                            });
                          },
                          child: Icon(new_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(0, 0, 0, 0),
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: main_theme().get_blue_grey(),
                          ),

                          //<-- SEE HERE
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      validator: (value) {
                        password_checker = validatePassword(value!);

                        if (value.isEmpty) {
                          return null;
                        } else {
                          if (password_checker) {
                            return null;
                          } else if (value.length <= 6) {
                            return "should be at least 6 characters";
                          } else {
                            return "should contain [A-Z,a-z,0-9,Special characters]";
                          }
                        }
                      },
                    ),
                  ),

                  ///
                  ///
                  Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Confirm new password",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Container(
                    child: TextFormField(
                      obscureText: confirm_obscure,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              confirm_obscure = !confirm_obscure;
                            });
                          },
                          child: Icon(confirm_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: password == password_confermation &&
                                    password_checker
                                ? BorderSide(color: Colors.green)
                                : BorderSide(color: Colors.red)),
                        errorStyle: TextStyle(
                            color: password == password_confermation &&
                                    password_checker
                                ? Colors.green
                                : Colors.red),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(0, 0, 0, 0),
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: main_theme().get_blue_grey(),
                          ),

                          //<-- SEE HERE
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          password_confermation = value;
                        });
                      },
                      validator: (value) {
                        if (password != "" && value != "") {
                          if (password != value) {
                            confirm = false;
                            return "Confirm password is not match.";
                          } else {
                            confirm = true;
                            return "Confirm password is match.";
                          }
                        }
                      },
                    ),
                  ),

                  Text(
                    "*By pressing on save you will be able to update your " +
                        widget.field +
                        ".",
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
