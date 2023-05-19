import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stuck_service/models/auth-service.dart';
import 'package:stuck_service/models/worngDialgo.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stuck_service/widgets/spinner.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class Sign_in extends StatefulWidget {
  const Sign_in({super.key});

  @override
  State<Sign_in> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Sign_in> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool showSpinner = false;
  bool obscure = true;
  late String email;
  late String password;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Future<void> setFCM(String email) async {
    requestNotificationPermission();
    await _fcm.getToken().then((value) async {
      await _firestore.collection("token").doc(email).set({
        'token': value,
      });
    });
    //configureFirebaseMessaging();
  }

  Future<bool> requestNotificationPermission() async {
    final PermissionStatus permissionStatus =
        await Permission.notification.request();
    return permissionStatus == PermissionStatus.granted;
  }

  void configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received notification: ${message.notification!.title}");
      // Display notification to the user using a notification package
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: ProgressWithIcon(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.lightBlueAccent),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          height: 150.0,
                          alignment: Alignment.topCenter,
                          child: Image.asset('assets/images/wheel-logo.png'),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      setState(() {
                        showSpinner = false;
                      });
                      return 'Please Enter your Email.';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 225, 239, 248),
                    labelText: "Enter your Email",
                    prefixIcon: Icon(Icons.email),
                    //hintText: 'Enter your email',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  obscureText: obscure,
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      setState(() {
                        showSpinner = false;
                      });
                      return 'Please Enter your Password.';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 225, 239, 248),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                      child: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                    labelText: "Enter your password.",
                    prefixIcon: Icon(Icons.lock),
                    //hintText: 'Enter your password.',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'forgotpassword');
                    },
                    child: Text('Forgot password?'),
                  ),
                  height: 35,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        if (!_formkey.currentState!.validate()) {
                          return;
                        }
                        try {
                          final user = await _auth.signInWithEmailAndPassword(
                              email: email, password: password);
                          final dataUser = await _firestore
                              .collection('userData')
                              .doc(email)
                              .get();
                          setFCM(email);
                          final String typeUser = dataUser.data()!['typeUser'];
                          if (user != null) {
                            Navigator.pushNamed(context, 'userpage',
                                arguments: typeUser);
                          }
                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          setState(() {
                            showSpinner = false;
                          });
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => worngDialgo(
                                  text: 'email or password is invalid.'));
                          print(e);
                        }
                      },
                      minWidth: 400.0,
                      height: 42.0,
                      child: Text(
                        'Sign in',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Color.fromARGB(255, 179, 62, 62),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async {
                      final user = await AuthService().signInWithGoogle();
                      if (user.additionalUserInfo?.isNewUser) {
                        print('isNew');
                      } else {
                        Navigator.pushNamed(context, 'userpage');
                      }
                    },
                    minWidth: 400.0,
                    height: 42.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Center(
                          child: Image(
                              width: 30,
                              image: AssetImage('assets/images/google.png')),
                        ),
                        Center(
                          child: Text(
                            '  Login With Google',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?'),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'registration');
                        },
                        child: Text('Sign up'),
                      ),
                      height: 35,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
