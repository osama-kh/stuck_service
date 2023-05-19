import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:stuck_service/Messenger/chatroom.dart';
import 'package:stuck_service/Messenger/chatscreen.dart';
import 'package:stuck_service/models/main_theme.dart';
import 'package:stuck_service/widgets/profile.dart';
import 'Sign in.dart';
import 'userPage.dart';

class side_drawer extends StatelessWidget {
  //final Profile_image;
  final dataOfUser;
  final image;
  final lastonline;
  final _auth;
  final context;
  side_drawer(
      this.dataOfUser, this.image, this.lastonline, this._auth, this.context);

  signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Sign_in()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Drawer(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: main_theme().get_blue_grey(), width: 3)),
                  color: main_theme().get_white(),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: image != null
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: greenORred(context),
                            )
                          : Container(
                              alignment: Alignment.topCenter,
                              child: CircleAvatar(
                                //   //foregroundImage: asset(Profile_image),
                                radius: MediaQuery.of(context).size.width * 0.2,
                                backgroundColor: main_theme().get_blue_grey(),
                                child: greenORred(context),
                                //  // backgroundImage: image!= null ? Image.file(image!):Image.asset('assets/images/stuck-man.png'),
                              ),
                            ),
                    ),
                    Flexible(
                      child: SizedBox(
                        height: 19,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => profile(dataOfUser)));
                      },
                      child: Text(
                        dataOfUser['Fullname'].toString(),
                        style: TextStyle(
                          color: main_theme().get_blue_grey(),
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Text(lastonline)
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to the home screen
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Chatscreen()));
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.43,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Sign out"),
              onTap: () {
                signOut();
              },
            )
          ],
        ),
      ),
    );
  }

  Stack greenORred(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: -MediaQuery.of(context).size.width * 0.2,
          bottom: -MediaQuery.of(context).size.width * 0.22,
          left: 0,
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dataOfUser["type"] == 'stucked'
                    ? Colors.green
                    : lastonline == 'online'
                        ? Colors.green
                        : Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
