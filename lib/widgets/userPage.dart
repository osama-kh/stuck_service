import 'dart:io';
import 'dart:math';
//--no-sound-null-safety
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stuck_service/models/helper.dart';
import 'package:stuck_service/models/stucked.dart';
import 'BarIndicator.dart';
import 'Helper_p.dart';
import 'Sign in.dart';
import 'Stuck_p.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
var dataOfUser;
var loggedInUser;
bool isHelper = false;
bool showSpinner = false;

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    dataOfUser = {
      "Fullname": "unknown",
      "phoneNumber": "unknown",
      "typeUser": "unknown"
    };
    isHelper = false;
    try {
      setState(() {
        showSpinner = true;
      });
      User? user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);

        final events = await _firestore
            .collection('userData')
            .doc(loggedInUser.email)
            .get();
        if (events != null) {
          dataOfUser = events.data();
          if (dataOfUser['typeUser'].toString() == "helper") {
            isHelper = true;
          }
          dataOfUser['Email'] = events.id;
          print(
              "dataof users ---------------------------------------------------------");
          print(dataOfUser.toString());
          setState(() {
            showSpinner = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        showSpinner = false;
      });
      print(e);
    }
  }

  // title: Text(dataOfUser['Fullname'].toString()),

  @override
  Widget build(BuildContext context) {
    final typeUser = ModalRoute.of(context)?.settings.arguments;
    bool ishelper = typeUser == 'helper' ? true : false;
    if (ishelper) {
      return ModalProgressHUD(
          inAsyncCall: showSpinner, child: Helper_p(dataOfUser));
    } else {
      print("current user");
      print(dataOfUser);
      print("current user");

      return ModalProgressHUD(
          inAsyncCall: showSpinner, child: Stuck_p(dataOfUser));
    }
  }
}
