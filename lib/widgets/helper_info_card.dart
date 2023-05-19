import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:stuck_service/Messenger/chatroom.dart';
import 'Stuck_p.dart';
import '../models/main_theme.dart';
import 'StarDisplay.dart';

class helper_info_card extends StatelessWidget {
  final helper_data;
  final helper_images;
  final distance;
  final helper_key_mail;
  const helper_info_card(this.helper_data, this.helper_images, this.distance,
      this.helper_key_mail);

  checker() {
    print(this.helper_data);

    print("-------------------------------------------infocard");
  }

  helper_full_data_dialog(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                children: <Widget>[
                  //Flexible(
                  //child:
                  helper_images != null
                      ? CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.1,
                          backgroundImage: NetworkImage(helper_images!),
                        )
                      : CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.1,
                          backgroundColor: main_theme().get_blue_grey(),
                        ),
                  //),
                  Text(helper_data["Fullname"].toString()),
                  SizedBox(
                    height: 10,
                  ),
                  Flexible(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Text("Description:"),
                            alignment: Alignment.topLeft,
                          ),
                          Flexible(
                              child: SizedBox(
                            height: double.infinity,
                          )),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Text("Full name: " +
                                //     helper_data["Fullname"].toString())

                                Row(
                                  children: [
                                    IconTheme(
                                      data: IconThemeData(
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      child: StarDisplay(value: 3),
                                    ),
                                    Flexible(
                                      child: SizedBox(
                                        width: double.infinity,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      chatroom(
                                                          helper_data,
                                                          helper_key_mail,
                                                          helper_images)));
                                        },
                                        icon: Icon(Icons.message)),
                                  ],
                                ),
                              ]),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 4;
    final width = MediaQuery.of(context).size.height / 4;
    //checker();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Flexible(
          child: Row(
            children: <Widget>[
              Flexible(
                child: helper_images != null
                    ? CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.1,
                        backgroundImage: NetworkImage(helper_images!),
                      )
                    : CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.1,
                        backgroundColor: main_theme().get_blue_grey(),
                      ),
              ),
              SizedBox(
                width: 50,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    helper_data["Fullname"].toString(),
                    style: TextStyle(fontSize: 23),
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          IconTheme(
                            data: IconThemeData(
                              color: Colors.amber,
                              size: 20,
                            ),
                            child: StarDisplay(value: 2),
                          ),
                          Text(
                              'Distance: ${(distance / 1000).toStringAsFixed(2)} km',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => chatroom(helper_data,
                                        helper_key_mail, helper_images)));
                          },
                          icon: Icon(Icons.message)),
                      IconButton(
                          onPressed: () {
                            print(distance.toString());
                            print("destance");
                            helper_full_data_dialog(context);
                          },
                          icon: Icon(Icons.article))
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
