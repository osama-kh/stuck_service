import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'Stuck_p.dart';
import '../models/main_theme.dart';
import 'StarDisplay.dart';

class notification_to_helper extends StatelessWidget {
  final waitingStucked;
  const notification_to_helper(this.waitingStucked);

  checker() {
    // print(this.helper_data);

    print("-------------------------------------------infocard");
  }

  notification_full_data_dialog(context) {
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
                  waitingStucked['senderImageUrl'] != null
                      ? CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.1,
                          backgroundImage:
                              NetworkImage(waitingStucked['senderImageUrl']),
                        )
                      : CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.1,
                          backgroundColor: main_theme().get_blue_grey(),
                        ),
                  //),
                  Text(""),
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
                            child: Text("Description:  " +
                                waitingStucked['noteDescription']),
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
                                Text(
                                    waitingStucked['senderFullname'].toString())
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Flexible(
          child: Row(
            children: <Widget>[
              Flexible(
                child: waitingStucked['senderImageUrl'] != null
                    ? CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.1,
                        backgroundImage:
                            NetworkImage(waitingStucked['senderImageUrl']),
                      )
                    : CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.1,
                        backgroundColor: main_theme().get_blue_grey(),
                      ),
              ),
              SizedBox(
                width: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    waitingStucked['senderFullname'],
                    style: TextStyle(fontSize: 23),
                  ),
                  Row(
                    children: [
                      Text(
                        "I need help!",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          notification_full_data_dialog(context);
                        },
                        icon: Icon(
                          Icons.read_more_rounded,
                          color: main_theme().get_blue_grey(),
                          size: 30,
                        ),
                        label: Text(
                          "info",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: main_theme().get_blue_grey()),
                        ),
                      ),
                      // IconButton(
                      //     onPressed: () {
                      //       notification_full_data_dialog(context);
                      //     },
                      //     icon: Icon(
                      //       Icons.read_more_rounded,
                      //       color: main_theme().get_blue_grey(),
                      //       size: 40,
                      //     ))
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
