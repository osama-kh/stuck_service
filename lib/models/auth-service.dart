import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stuck_service/widgets/UserPage.dart';
import 'package:stuck_service/widgets/cardslist.dart';


class AuthService {
  var Isnew;
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return UserPage();
          } else {
            return Cardlist();
          }
        });
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    print('1');
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();
    print('2');
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    print('3');
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('4');
    // Once signed in, return the UserCredential
    final user = await FirebaseAuth.instance.signInWithCredential(credential);
    Isnew = await user.additionalUserInfo!.isNewUser;
    print(Isnew);
    return user;
  }

  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
