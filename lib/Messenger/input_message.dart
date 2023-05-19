import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:stuck_service/Messenger/chatroom.dart';
import 'package:stuck_service/models/main_theme.dart';
import 'package:stuck_service/widgets/Stuck_p.dart';
import 'package:stuck_service/widgets/userPage.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class input_message extends StatefulWidget {
  final user_data;
  final user_key_mail;
  final user_image;
  final usermail;

  input_message(
      this.user_data, this.user_key_mail, this.user_image, this.usermail);

  @override
  State<input_message> createState() => _input_messageState();
}

class _input_messageState extends State<input_message> {
  @override
  void initState() {
    // TODO: implement initState
    getTokens();
    super.initState();
  }

  var text_f;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Map<dynamic, dynamic> userTokens = {};
  String message_body = "";

  final myController = TextEditingController();
  File? imagefile;
  Future getImage_gallary() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((XFile) {
      if (XFile != null) {
        imagefile = File(XFile.path);
        send_image_dialog(context);
      }
    });
  }

  Future getImage_camera() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.camera).then((XFile) {
      if (XFile != null) {
        imagefile = File(XFile.path);
        send_image_dialog(context);
      }
    });
  }

  Future uploadImage() async {
    DateTime date = DateTime.now();
    String date_format = DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String formattedTime = DateFormat('HH:mm').format(date);
    String filename = Uuid().v1();

    var ref = FirebaseStorage.instance
        .ref()
        .child("messengerImages")
        .child("$filename.jpg");
    var uploadTask = await ref.putFile(imagefile!);
    String ImageUrl = await uploadTask.ref.getDownloadURL();

    _firestore.collection("Messenger").add({
      "ImageUrlChat": ImageUrl,
      "receiver": widget.user_key_mail,
      "sender": widget.usermail,
      "senderImageUrl": UsersImagesUrls[widget.usermail],
      "senderFullname": dataOfUser['Fullname'].toString(),
      "senderPhone": dataOfUser['phoneNumber'],
      "receiverFullname": this.widget.user_data["Fullname"],
      "receiverImageUrl": this.widget.user_image,
      "receiverPhone": this.widget.user_data["phoneNumber"],
      "time": formattedTime,
      "date": formattedDate,
      "FullDate": date_format
    });
    // print("input print img");
    // print(this.widget.user_image);
    _firestore.collection("Messenger_os").add({
      "receiver": widget.user_key_mail,
      "sender": widget.usermail,
    });
    print(ImageUrl);
  }

  Future send_image_dialog(context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Colors.black,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      image: DecorationImage(image: FileImage(imagefile!))),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: IconButton(
                        icon: Transform.scale(
                            scaleX: -1,
                            child: Icon(
                              Icons.send,
                              size: 30,
                            )),
                        color: main_theme().get_blue_grey(),
                        onPressed: () {
                          uploadImage();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 90,
                      height: 60,
                      child: Text(
                          "Send to " +
                              this.widget.user_data["Fullname"].toString(),
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void getTokens() async {
    userTokens = {};
    final collection = FirebaseFirestore.instance.collection('token');
    final snapshot = await collection.get();
    snapshot.docs.forEach((doc) {
      userTokens.putIfAbsent(doc.id, () => doc.data());
    });
  }

  Future<void> sendNotification(String title, String body) async {
    await dotenv.load();
    User? user = _auth.currentUser;
    if (userTokens[widget.user_data["Email"]] != null) {
      final data = {
        'notification': {'title': title, 'body': body},
        'priority': 'high',
        'to': userTokens[widget.user_data["Email"]]['token'],
      };
      final KEY = dotenv.env['NOTIFICATION_KEY'];
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$KEY',
      };
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headers,
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        var idkey = user!.email! + ' ' + widget.user_data["Email"];
        await _firestore.collection("messageNotifications").doc(idkey).set({
          'sender': user!.email,
          'noteDescription': body,
          'receiver': widget.user_data["Email"]
        });
        print('Notification sent');
      } else {
        print('Error sending notification');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    String date_format = DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String formattedTime = DateFormat('HH:mm').format(date);
    //User? user = _auth.currentUser;
    var kDefaultPadding = 20.0;
    return Column(
      children: [
        //Spacer(),
        Container(
          //padding: EdgeInsets.all(10),
          padding: EdgeInsets.symmetric(
              horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),

          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 32,
                  color: main_theme().get_blue_grey().withOpacity(0.5))
            ],
            color: main_theme().get_white(),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Transform.scale(
                      scaleX: -1,
                      child: Icon(
                        Icons.send,
                        size: 30,
                      )),
                  color: main_theme().get_blue_grey(),
                  onPressed: () async {
                    print(myController.text);
                    print(widget.user_data);
                    _firestore.collection("Messenger").add({
                      "chat": message_body,
                      "receiver": widget.user_key_mail,
                      "sender": widget.usermail,
                      "senderImageUrl": UsersImagesUrls[widget.usermail],
                      "senderFullname": dataOfUser['Fullname'].toString(),
                      "senderPhone": dataOfUser['phoneNumber'],
                      "receiverFullname": this.widget.user_data["Fullname"],
                      "receiverImageUrl": this.widget.user_image,
                      "receiverPhone": this.widget.user_data["phoneNumber"],
                      "time": formattedTime,
                      "date": formattedDate,
                      "FullDate": date_format
                    });

                    await sendNotification(
                        'new message from ' + dataOfUser['Fullname'].toString(),
                        message_body);
                    print("input print img");
                    print(this.widget.user_image);
                    _firestore.collection("Messenger_os").add({
                      "receiver": widget.user_key_mail,
                      "sender": widget.usermail,
                    });
                    myController.clear();

                    // chatroom().createState().build(context);
                  },
                ),
                // SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: kDefaultPadding * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: main_theme().get_blue_grey().withOpacity(0.05),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        // Icon(
                        //   Icons.sentiment_satisfied_alt_outlined,
                        //   color: Theme.of(context)
                        //       .textTheme
                        //       .bodyText1!
                        //       .color!
                        //       .withOpacity(0.64),
                        // ),
                        SizedBox(width: kDefaultPadding / 4),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                message_body = value;
                              });
                            },
                            controller: myController,
                            decoration: InputDecoration(
                              hintText: "Type message",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () => getImage_gallary(),
                            icon: Icon(
                              Icons.photo,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.64),
                            )),
                        SizedBox(width: kDefaultPadding / 4),
                        IconButton(
                          onPressed: () => getImage_camera(),
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .color!
                                .withOpacity(0.64),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
