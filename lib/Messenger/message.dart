import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:stuck_service/models/main_theme.dart';

class message extends StatelessWidget {
  final is_sender;
  final messege_data;
  // final text;
  // final sender;
  // final receiver;

  // message(this.is_sender, this.text, this.sender, this.receiver);

  message(
    this.is_sender,
    this.messege_data,
  );
  Future show_image_dialog(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                // alignment: Alignment.topRight,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        width: double.infinity,
                      )),
                      IconButton(
                        icon: Transform.scale(
                            scaleX: 1,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 40,
                            )),
                        color: main_theme().get_blue_grey(),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                            image: NetworkImage(
                                messege_data["ImageUrlChat"].toString()))),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var kDefaultPadding = 20.0;
    DateTime date = DateTime.now();
    String formattedDate = "${date.day}/${date.month}/${date.year}";
    String formattedTime = "${date.hour}:${date.minute}";
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment:
              is_sender ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: kDefaultPadding * 0.75,
                  vertical: kDefaultPadding / 2),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: is_sender == true
                          ? main_theme().get_blue_grey()
                          : main_theme().get_white()),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: is_sender == true
                      ? main_theme().get_white()
                      : main_theme().get_blue_grey()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  messege_data["chat"] != null
                      ? Text(
                          // text.toString(),
                          messege_data["chat"].toString(),
                          style: TextStyle(
                              color: is_sender ? Colors.black : Colors.white,
                              fontSize: 16),
                        )
                      : GestureDetector(
                          onTap: () => show_image_dialog(context),
                          child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                        messege_data["ImageUrlChat"]
                                            .toString()))),
                          ),
                        ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    messege_data["date"].toString() +
                        "  " +
                        messege_data["time"].toString(),
                    style: TextStyle(
                        color: is_sender ? Colors.black : Colors.white,
                        fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
