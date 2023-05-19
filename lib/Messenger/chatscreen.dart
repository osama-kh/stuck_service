import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:stuck_service/Messenger/chatroom_User_card.dart';
import '../models/main_theme.dart';

class Chatscreen extends StatefulWidget {
  Chatscreen();

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  var indxs = 0;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    List chat_users = [];
    List chat_users_2_user = [];
    Set distinct_chat_users_2_user = Set();
    var kDefaultPadding = 20.0;

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: main_theme().get_blue_grey()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Chat',
              style: TextStyle(color: main_theme().get_blue_grey())),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: StreamBuilder(
          stream: _firestore.collection('Messenger_os').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              print(snapshot.error);
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              snapshot.data?.docs.forEach((element) {
                if (element.exists) {
                  if (element.data()["receiver"] == user!.email) {
                    distinct_chat_users_2_user.add(element.data()["sender"]);
                  } else if (element.data()["sender"] == user!.email) {
                    distinct_chat_users_2_user.add(element.data()["receiver"]);
                  }
                  print(element.data().toString());
                  chat_users_2_user.add(element.data());
                }
              }) as List;
              print("mailes of users to user");
              print(user!.phoneNumber);

              return StreamBuilder(
                  stream: _firestore.collection('Messenger').snapshots(),
                  builder: (context, snapshot2) {
                    if (!snapshot2.hasData) {
                      print(snapshot2.error);
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      List<Map<String, dynamic>> chat_usersname = [];
                      print("displayName");
                      print(user!.displayName.toString());
                      snapshot2.data?.docs.forEach((element) {
                        if (element.exists) {
                          print(element.data().toString());
                          if (element.data()["receiver"] == user!.email ||
                              element.data()["sender"] == user!.email) {
                            chat_users.add(element.data());
                            if (distinct_chat_users_2_user
                                .contains(element.data()["receiver"])) {
                              chat_usersname.add({
                                "Email": element.data()["receiver"].toString(),
                                "ImageUrl": element
                                    .data()["receiverImageUrl"]
                                    .toString(),
                                "Fullname": element
                                    .data()["receiverFullname"]
                                    .toString(),
                                "phoneNumber":
                                    element.data()["receiverPhone"].toString(),
                              });
                            } else if (distinct_chat_users_2_user
                                .contains(element.data()["sender"])) {
                              chat_usersname.add({
                                "Email": element.data()["sender"].toString(),
                                "ImageUrl":
                                    element.data()["senderImageUrl"].toString(),
                                "Fullname":
                                    element.data()["senderFullname"].toString(),
                                "phoneNumber":
                                    element.data()["senderPhone"].toString(),
                              });
                            }
                          }
                          // chat_users.add(element.data());
                        }
                      }) as List;
                      List temp = [];

                      List<Map<String, dynamic>> distinctList = chat_usersname
                          .fold<List<Map<String, dynamic>>>([],
                              (accumulator, map) {
                        if (!accumulator.any((item) =>
                            item['Email'] == map['Email'] &&
                            item['ImageUrl'] == map['ImageUrl'] &&
                            item['Fullname'] == map['Fullname'] &&
                            item['phoneNumber'] == map['phoneNumber'])) {
                          accumulator.add(map);
                        }
                        return accumulator;
                      });

                      chat_users.sort(
                          (a, b) => a["FullDate"].compareTo(b["FullDate"]));

                      print(distinctList);

                      for (var i = 0; i < distinctList.length; i++) {
                        temp.add(
                            chatroom_User_card(chat_users, distinctList[i]));
                        print("fffffffff");
                        print(distinctList[i]);
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: kDefaultPadding),
                              child: ListView.builder(
                                  itemCount: temp.length,
                                  itemBuilder: (context, index) => temp[index]
                                  // chatroom_User_card(chat_users, distinctList[index]),
                                  ),
                            ),
                          ),
                        ],
                      );
                    }
                  });
            }
          },
        ));
  }
}




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:stuck_service/Messenger/chatroom_User_card.dart';

// import '../models/main_theme.dart';

// class Chatscreen extends StatefulWidget {
//   Chatscreen();

//   @override
//   State<Chatscreen> createState() => _ChatscreenState();
// }

// class _ChatscreenState extends State<Chatscreen> {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//   var indxs = 0;


//   @override
//   Widget build(BuildContext context) {
    
    
//     User? user = _auth.currentUser;
//     List chat_users = [];
//     var kDefaultPadding = 20.0;

//     return Scaffold(
//         appBar: AppBar(
//           iconTheme: IconThemeData(color: main_theme().get_blue_grey()),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           title: Text('Chat',
//               style: TextStyle(color: main_theme().get_blue_grey())),
//           leading: IconButton(
//               icon: Icon(Icons.arrow_back_rounded),
//               onPressed: () {
//                 Navigator.pop(context);
//               }),
//         ),
//         body: StreamBuilder(
//           stream: _firestore
//               .collection('Messenger')
//               .where("sender", isEqualTo: user!.email)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               print(snapshot.error);
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else {
//               List temp = [];
//               chat_users = [];
//               List<Map<String, dynamic>> chat_usersname = [];

//               snapshot.data?.docs.forEach((element) {
//                 if (element.exists) {
//                   print(element.data().toString());
//                   chat_users.add(element.data());
//                   chat_usersname.add({
//                     "receiver": element.data()["receiver"].toString(),
//                     // "receiverImageUrl":
//                     //     element.data()["receiverImageUrl"].toString(),
//                     "receiverFullname":
//                         element.data()["receiverFullname"].toString(),
//                   });
//                 }
//               }) as List;
//               print(chat_users);

//               List<Map<String, dynamic>> distinctList = chat_usersname
//                   .fold<List<Map<String, dynamic>>>([], (accumulator, map) {
//                 if (!accumulator.any((item) =>
//                     item['receiver'] == map['receiver'] &&
//                     // item['receiverImageUrl'] == map['receiverImageUrl'] &&
//                     item['receiverFullname'] == map['receiverFullname'])) {
//                   accumulator.add(map);
//                 }
//                 return accumulator;
//               });

//               chat_users.sort((a, b) => a["FullDate"].compareTo(b["FullDate"]));

//               print("chat_users.length");
//               print(distinctList);
//               for (var i = 0; i < distinctList.length; i++) {
//                 temp.add(chatroom_User_card(chat_users, distinctList[i]));
//                 print("fffffffff");
//                 print(distinctList[i]);
//               }
//               return Column(
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
//                       child: ListView.builder(
//                           itemCount: temp.length,
//                           itemBuilder: (context, index) => temp[index]
//                           // chatroom_User_card(chat_users, distinctList[index]),
//                           ),
//                     ),
//                   ),
//                 ],
//               );
//             }
//           },
//         ));
//   }
// }
