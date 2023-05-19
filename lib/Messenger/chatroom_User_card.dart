import 'package:flutter/material.dart';
import 'package:stuck_service/Messenger/chatroom.dart';
import 'package:stuck_service/models/main_theme.dart';
import 'package:stuck_service/widgets/Stuck_p.dart';

class chatroom_User_card extends StatelessWidget {
  var messanger_user_name = "mohammed";
  final chat_users;
  var chat_user;
  final chat_users_name_image;
  chatroom_User_card(this.chat_users, this.chat_users_name_image);

  // Map userpicker() {

  //   for(var indx in chat_users){
  //       if()

  //   }

  //   return {};
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("chat_users_name_image");
        print(chat_users_name_image);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => chatroom(
                    chat_users_name_image,
                    chat_users_name_image["Email"],
                    chat_users_name_image["ImageUrl"])));
      },
      child: Container(
        decoration: BoxDecoration(
            //borderRadius: BorderRadius.all(Radius.circular(12)),
            border: Border.symmetric(
                horizontal: BorderSide(
                    color: main_theme().get_blue_grey().withOpacity(0.05)))),
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              chat_users_name_image['Fullname'].toString(),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(width: 20),
            CircleAvatar(
              backgroundImage: NetworkImage(chat_users_name_image["ImageUrl"]),
              radius: 35,
            )
          ],
        ),
      ),
    );
  }
}
