import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:stuck_service/Messenger/input_message.dart';
import 'package:stuck_service/Messenger/message.dart';
import 'package:stuck_service/models/main_theme.dart';

class chatroom extends StatefulWidget {
  final helper_data;
  final helper_key_mail;
  final helper_distance;
  final helper_image;
  chatroom(this.helper_data, this.helper_key_mail, this.helper_distance,
      this.helper_image);

  @override
  State<chatroom> createState() => _chatroomState();
}

class _chatroomState extends State<chatroom> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  AppBar App_bar() {
    return AppBar(
      backgroundColor: main_theme().get_blue_grey(),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          BackButton(),
          CircleAvatar(),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "name",
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
      actions: [IconButton(onPressed: () {}, icon: Icon(Icons.local_phone))],
    );
  }

  List message_list = [
    // message(true, "hi there", "sender", "receiver"),
    // message(false, "how are you?", "sender", "receiver"),
    // message(true, "fine , what about you?", "sender", "receiver"),
    // message(false, "never been better", "sender", "receiver"),
  ];



  @override
  Widget build(BuildContext context) {
    var kDefaultPadding = 20.0;
    User? user = _auth.currentUser;
    List messeges = [];
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
                    .where("receiver", isEqualTo: user!.email)
                    .where("sender", isEqualTo: widget.helper_key_mail)
                    // .orderBy("FullDate", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  print("-/////////////----------");
                  // if(snapshot.connectionState== ConnectionState.done)
                  if (!snapshot.hasData) {
                    print(snapshot.error);
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    print("there data");
                    final documents = snapshot.data?.docs;
                    // setState(() {});
                    snapshot.data?.docs.forEach((element) {
                      if (element.exists) {
                        print(element.data().toString());
                        messeges.add(message(element["receiver"] == user.email,
                                element.data())

                            // element.data()3
                            );
                      }
                    }) as List;

                    var i = 0;

                    print(messeges.toString());
                    print(messeges.length);

                    return ListView.builder(
                        itemCount: messeges.length,
                        itemBuilder: (context, index) => messeges[index]

                        // message(
                        //     messeges[index]["receiver"] == user.email,
                        //     messeges[index])
                        );
                  }
                },
              ),
            ),
          ),
          // input_message(widget.helper_data, widget.helper_key_mail,
          //     widget.helper_image, user.email)
        ],
      ),
    );
  }
}
















// @override
//   Widget build(BuildContext context) {
//     var kDefaultPadding = 20.0;
//     User? user = _auth.currentUser;

//     return Scaffold(
//       appBar: App_bar(),
//       body: Column(
//         children: [
//           Expanded(
//             child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
//                 child: MessageStream(widget.helper_key_mail)),
//           ),
//           input_message(widget.helper_data, widget.helper_key_mail,
//               widget.helper_image, user!.email)
//         ],
//       ),
//     );
//   }
// }