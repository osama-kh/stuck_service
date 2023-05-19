import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stuck_service/widgets/profile.dart';

import '../models/main_theme.dart';
import '../models/worngDialgo.dart';

class updatefield extends StatefulWidget {
  String field;
  var field_data;
  var dataOfUser;

  updatefield(this.field, this.field_data, this.dataOfUser);

  @override
  State<updatefield> createState() => _updatefieldState();
}

class _updatefieldState extends State<updatefield> {
  String field_t = "";
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  void intilaize_field_t() {
    if (widget.field == "Fullname") {
      field_t = "Full name";
    } else if (widget.field == "phoneNumber") {
      field_t = "Phone number";
    }
  }

  final _firestore = FirebaseFirestore.instance;

  var newValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_theme().get_white(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: main_theme().get_blue_grey()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: widget.field == "Fullname"
            ? Text("Full name",
                style: TextStyle(color: main_theme().get_blue_grey()))
            : widget.field == "phoneNumber"
                ? Text("Phone number",
                    style: TextStyle(color: main_theme().get_blue_grey()))
                : Text(widget.field,
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
                if (newValue == '') {
                } else {
                  if (widget.field == 'Fullname') {
                    await _firestore
                        .collection("userData")
                        .doc(widget.dataOfUser['Email'])
                        .set({
                      widget.field: newValue,
                      'phoneNumber': widget.dataOfUser['phoneNumber'],
                      'typeUser': widget.dataOfUser['typeUser'],
                    });
                    widget.dataOfUser[widget.field] = newValue;
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            worngDialgo(text: 'update successfully'));
                  } else if (widget.field == 'phoneNumber') {
                    await _firestore
                        .collection("userData")
                        .doc(widget.dataOfUser['Email'])
                        .set({
                      'Fullname': widget.dataOfUser['Fullname'],
                      widget.field: newValue,
                      'typeUser': widget.dataOfUser['typeUser'],
                    });

                    widget.dataOfUser[widget.field] = newValue;
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            worngDialgo(text: 'update successfully'));
                  }
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
              color: Colors.black12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 50,
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 3, left: 3),
                    child: TextFormField(
                      keyboardType: widget.field == "phoneNumber"
                          ? TextInputType.phone
                          : TextInputType.text,
                      validator: (value) {
                        if (value == "") {
                          return "Empty Field!";
                        }
                      },
                      decoration: InputDecoration(
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
                      initialValue: widget.field_data,
                      onChanged: (value) {
                        newValue = value;
                        if (value == '') {}
                      },
                    ),
                  ),
                  widget.field == "Fullname"
                      ? Text(
                          "*By pressing on save you will be able to update your full name.",
                          style: TextStyle(fontSize: 10),
                        )
                      : widget.field == "phoneNumber"
                          ? Text(
                              "*By pressing on save you will be able to update your phone number.",
                              style: TextStyle(fontSize: 10),
                            )
                          : Text(
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
