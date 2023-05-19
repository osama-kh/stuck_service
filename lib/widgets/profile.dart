import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stuck_service/widgets/Helper_p.dart';
import 'package:stuck_service/widgets/UpdateProfileData.dart';
import 'package:stuck_service/widgets/UserPage.dart';
import 'package:stuck_service/widgets/cards.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stuck_service/widgets/change_password.dart';
import 'package:stuck_service/widgets/userPage.dart';
import '../models/main_theme.dart';
import 'package:http/http.dart' as http;

import '../models/worngDialgo.dart';

class profile extends StatefulWidget {
  var dataOfUser;
  profile(this.dataOfUser);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final _storage = FirebaseStorage.instance;
  File? image;
  Uint8List? imageData;
  bool showSpinner = false;
  @override
  void initState() {
    super.initState();
    getImageData();
  }

  Future pickImage() async {
    setState(() {
      showSpinner = true;
    });
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        this.image = imageTemp;
      });
      if (image != null) {
        final ref =
            await _storage.ref().child('images/${widget.dataOfUser['Email']}');
        await ref.putFile(imageTemp);

        getImageData();
      }
    } on PlatformException catch (e) {
      print('Faild to pick image: $e');
    }
  }

  Future<void> getImageData() async {
    setState(() {
      showSpinner = true;
    });
    try {
      final ref =
          await _storage.ref().child('images/${widget.dataOfUser['Email']}');
      // Get the download URL
      final String downloadURL = await ref.getDownloadURL();

      // Read the image data from the URL
      final response = await http.get(Uri.parse(downloadURL));
      imageData = response.bodyBytes;
      setState(() {});
    } catch (e) {
      print(e);
    }
    setState(() {
      showSpinner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: main_theme().get_white(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: main_theme().get_blue_grey()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Profile',
              style: TextStyle(color: main_theme().get_blue_grey())),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded),
              onPressed: () {
                Navigator.pop(context, widget.dataOfUser);
              }),
        ),
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: imageData != null
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: MemoryImage(imageData!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: iconImage(Icon(Icons.update)),
                    )
                  : Container(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        //   //foregroundImage: asset(Profile_image),
                        radius: MediaQuery.of(context).size.width * 0.3,
                        backgroundColor: main_theme().get_blue_grey(),
                        child: iconImage(Icon(Icons.add_a_photo_rounded)),
                        //  // backgroundImage: image!= null ? Image.file(image!):Image.asset('assets/images/stuck-man.png'),
                      ),
                    ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "user info",
                    style: TextStyle(fontSize: 19),
                  ),
                  Container(
                      color: Colors.black12,
                      child: Column(
                        children: <Widget>[
                          Card(
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => updatefield(
                                          "Fullname",
                                          widget.dataOfUser['Fullname']
                                              .toString(),
                                          widget.dataOfUser),
                                    ));
                              },
                              child: TextFormField(
                                enabled: false,
                                controller: TextEditingController(
                                    text: widget.dataOfUser['Fullname']
                                        .toString()),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    labelText: "Full name",
                                    labelStyle: TextStyle(color: Colors.black)),
                                //initialValue: data['Fullname'].toString(),
                              ),
                            ),
                          ),
                          Card(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => updatefield(
                                            "phoneNumber",
                                            widget.dataOfUser['phoneNumber']
                                                .toString(),
                                            widget.dataOfUser)));
                              },
                              child: TextFormField(
                                enabled: false,
                                controller: TextEditingController(
                                    text: widget.dataOfUser['phoneNumber']
                                        .toString()),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    labelText: "Phone number",
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                    )),
                                //initialValue:widget.dataOfUser['phoneNumber'].toString(),
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Text(
                    "connection info",
                    style: TextStyle(fontSize: 19),
                  ),
                  Container(
                      color: Colors.black12,
                      child: Column(
                        children: <Widget>[
                          Card(
                            child: TextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black12,
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.black)),
                              initialValue:
                                  widget.dataOfUser['Email'].toString(),
                            ),
                          ),
                          Card(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => change_password(
                                            "Password",
                                            widget.dataOfUser['Password']
                                                .toString(),
                                            widget.dataOfUser)));
                              },
                              child: TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    labelText: "Password",
                                    labelStyle: TextStyle(color: Colors.black)),
                                initialValue: '********',
                              ),
                            ),
                          )
                        ],
                      ))
                ]))
          ],
        ),
      ),
    );
  }

  Widget iconImage(Icon icon) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: -MediaQuery.of(context).size.width * 0.4,
          bottom: -MediaQuery.of(context).size.width * 0.4,
          left: 0,
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: Center(
                child: IconButton(
                  icon: icon,
                  onPressed: () {
                    pickImage();
                    print('-----------');
                    print(image);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
