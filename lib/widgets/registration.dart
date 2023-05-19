import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stuck_service/models/worngDialgo.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:stuck_service/widgets/spinner.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

enum User { init, helper, stucked }

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late String email;
  late String password;
  String phoneNumber = '';
  String Fullname = '';
  bool password_conf = true;
  User selectedUser = User.init;
  bool obscure = true;
  bool confirm_obscure = true;
  Color inactiveColor = Colors.lightBlueAccent;
  Color activeColor = Colors.red.shade300;
  double bordersize = 1;

  RegExp pass_valid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  //A function that validate user entered password
  bool validatePassword(String pass) {
    String _password = pass.trim();
    if (pass_valid.hasMatch(_password)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: ProgressWithIcon(),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: const Text(
                      'Create new account',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    alignment: Alignment.topCenter,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'WHO YOU ARE?',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedUser = User.helper;
                              });
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: selectedUser == User.helper
                                        ? activeColor
                                        : (inactiveColor),
                                    width: selectedUser == User.helper ? 6 : 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.asset('assets/images/helper.png'),
                              ),
                            ),
                          ),
                          const Text(
                            'Helper',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedUser = User.stucked;
                              });
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: selectedUser == User.stucked
                                        ? activeColor
                                        : (inactiveColor),
                                    width:
                                        selectedUser == User.stucked ? 6 : 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child:
                                    Image.asset('assets/images/stuck-man.png'),
                              ),
                            ),
                          ),
                          Text(
                            'Stucked',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                      onChanged: (value) {
                        Fullname = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter your full name.';
                        } else {
                          return null;
                        }
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter Full name',
                        prefixIcon: Icon(Icons.person),
                      )),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter your Email.';
                        } else {
                          return null;
                        }
                      },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email))),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                      onChanged: (value) {
                        phoneNumber = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter your Phone Number.';
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.phone,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter PhoneNumber',
                          prefixIcon: Icon(Icons.phone))),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    obscureText: obscure,
                    toolbarOptions: const ToolbarOptions(
                      copy: true,
                      cut: true,
                      paste: false,
                      selectAll: false,
                    ),
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      bool password_checker = validatePassword(value!);

                      if (value.isEmpty) {
                        return 'Please Enter your Password.';
                      } else {
                        if (password_checker) {
                          return null;
                        } else if (value.length <= 6) {
                          return "should be at least 6 characters";
                        } else {
                          return "should contain [A-Z,a-z,0-9,Special characters]";
                        }
                      }
                    },
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                        child: Icon(
                            obscure ? Icons.visibility : Icons.visibility_off),
                      ),
                      hintText: 'Enter your password.',
                      prefixIcon: Icon(Icons.lock),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    obscureText: confirm_obscure,
                    toolbarOptions: const ToolbarOptions(
                      copy: true,
                      cut: true,
                      paste: false,
                      selectAll: false,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == '') {
                          print('hhhh');
                        }
                        if (value == password || value == '') {
                          password_conf = true;
                        } else {
                          password_conf = false;
                        }
                      });
                      //Do something with the user input.
                    },
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            confirm_obscure = !confirm_obscure;
                          });
                        },
                        child: Icon(confirm_obscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      hintText: 'Confirm your password.',
                      prefixIcon: Icon(Icons.lock),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),
                  Container(
                    height: 30,
                    padding: EdgeInsetsDirectional.only(start: 30, top: 10),
                    alignment: Alignment.centerLeft,
                    child: password_conf == false
                        ? Text(
                            "Password are not matching",
                            style: TextStyle(color: Colors.red),
                          )
                        : Text(''),
                  ),
                  // SizedBox(
                  //   height: 24.0,
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: MaterialButton(
                        onPressed: () async {
                          try {
                            if (!_formkey.currentState!.validate()) {
                              return;
                            }
                            if (password_conf) {
                              if (selectedUser.name != 'init') {
                                setState(() {
                                  showSpinner = true;
                                });
                                final newUser =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: email, password: password);

                                if (newUser != null) {
                                  await _firestore
                                      .collection("userData")
                                      .doc(email)
                                      .set({
                                    'Fullname': Fullname,
                                    'phoneNumber': phoneNumber,
                                    'typeUser': selectedUser.name,
                                  });
                                  if (selectedUser.name == 'helper') {
                                    DateTime now = DateTime.now();
                                    String formattedDate =
                                        "${now.day}/${now.month}/${now.year}";
                                    String formattedTime =
                                        "${now.hour}:${now.minute}:${now.second}";
                                    await _firestore
                                        .collection("helperStatus")
                                        .doc(email)
                                        .set({
                                      'status': 'offline',
                                      'lastDate': formattedDate,
                                      'lastTime': formattedTime
                                    });
                                  }

                                  setState(() {
                                    showSpinner = false;
                                  });
                                  Navigator.pushNamed(context, 'userpage');
                                }
                                setState(() {
                                  showSpinner = false;
                                });
                              } else {
                                setState(() {
                                  showSpinner = false;
                                });
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        worngDialgo(
                                            text: 'choose Helper or Stucked'));
                              }
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'email-already-in-use') {
                              setState(() {
                                showSpinner = false;
                              });
                              showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => worngDialgo(
                                      text:
                                          'The email address is already in use by another account.'));
                              print(e);
                            }
                          }
                        },
                        minWidth: 200.0,
                        height: 42.0,
                        child: Text(
                          'Sign up',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account.'),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'login');
                          },
                          child: Text('Sign in here'),
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
      ),
    );
  }
}

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  prefixIcon: null,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
