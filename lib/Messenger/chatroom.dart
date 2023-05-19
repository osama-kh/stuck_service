import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:stuck_service/Messenger/input_message.dart';
import 'package:stuck_service/Messenger/message.dart';
import 'package:stuck_service/models/main_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class chatroom extends StatefulWidget {
  final user_data;
  final user_key_mail;
  final user_image;
  chatroom(this.user_data, this.user_key_mail, this.user_image);

  @override
  State<chatroom> createState() => _chatroomState();
}

class _chatroomState extends State<chatroom> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List messeges = [];
  AppBar App_bar() {
    return AppBar(
      backgroundColor: main_theme().get_blue_grey(),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          BackButton(),
          CircleAvatar(
            backgroundImage: NetworkImage(widget.user_image.toString()),
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user_data["Fullname"] != null
                    ? widget.user_data["Fullname"].toString()
                    : widget.user_data["receiverFullname"].toString(),
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "active",
                style: TextStyle(fontSize: 12),
              )
            ],
          )
        ],
      ),
      actions: [
        IconButton(
            onPressed: () async {
              var number = widget.user_data['phoneNumber'];
              print("tel://$number");
              // ignore: deprecated_member_use
              launch("tel://$number");

              print(widget.user_data["phoneNumber"]);
            },
            icon: Icon(Icons.local_phone))
      ],
    );
  }

  List message_list = [
    // message(true, "hi there", "sender", "receiver"),
    // message(false, "how are you?", "sender", "receiver"),
    // message(true, "fine , what about you?", "sender", "receiver"),
    // message(false, "never been better", "sender", "receiver"),
  ];
  void call_state() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var kDefaultPadding = 20.0;
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: App_bar(),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Messenger')
                    // .where("sender", isEqualTo: user!.email)
                    // .where("receiver", isEqualTo: widget.user_key_mail)
                    // .orderBy("FullDate", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  print("-/////////////----------");
                  if (!snapshot.hasData) {
                    print(snapshot.error);
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    print("there data");
                    final documents = snapshot.data?.docs;
                    messeges = [];
                    message_list = [];
                    snapshot.data?.docs.forEach((element) {
                      if (element.exists) {
                        print(element.data().toString());

                        messeges.add(element.data());
                      }
                    }) as List;

                    messeges.forEach((element) {
                      if (element["sender"] == user!.email &&
                              element["receiver"] ==
                                  widget.user_data["Email"] ||
                          element["receiver"] == user!.email &&
                              element["sender"] == widget.user_data["Email"]) {
                        message_list.add(element);
                      }
                    });

                    messeges = message_list;
                    messeges
                        .sort((a, b) => a["FullDate"].compareTo(b["FullDate"]));
                    var i = 0;

                    print(messeges.toString());
                    print(messeges.length);

                    return ListView.builder(
                        itemCount: messeges.length,
                        itemBuilder: (context, index) => message(
                            messeges[index]["sender"] == user!.email,
                            messeges[index])
                        // messeges[index]

                        // message(
                        //     messeges[index]["receiver"] == user.email,
                        //     messeges[index])
                        );
                  }
                },
              ),
            ),
          ),
          input_message(widget.user_data, widget.user_key_mail,
              widget.user_image, user!.email)
        ],
      ),
    );
  }
}
