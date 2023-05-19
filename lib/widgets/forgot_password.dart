import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stuck_service/models/worngDialgo.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _Forgot_password createState() => _Forgot_password();
}

class _Forgot_password extends State<ForgotPassword> {
  final emailController = TextEditingController();
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Container(
                  height: 235,
                  child: Image.asset('assets/images/lock.png'),
                ),
              ),
              Container(
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  'Forgot password',
                  style: TextStyle(
                      color: Color.fromARGB(255, 27, 133, 220),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  height: 40.0,
                  child: Text(
                    'Check your email to rest your password',
                    style: TextStyle(fontSize: 17.0, color: Colors.blueGrey),
                  ),
                ),
              ),
              TextFormField(
                controller: emailController,
                onChanged: (value) {
                  //Do something with the user input.
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Email not enterd";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () {
                      if (!_formkey.currentState!.validate()) {
                        return;
                      }
                      print(emailController.text.trim());
                      restPassword();
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: Text(
                      'Rest Password',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
                ),
              ),
              Container(
                height: 35,
                child: TextButton(
                  child: Text(
                    'Go back',
                    style: TextStyle(fontSize: 15),
                  ),
                  onPressed: (() {
                    Navigator.pushNamed(context, 'login');
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future restPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      final snackBar = SnackBar(
        content: const Text('Password Reset Email Sent'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) =>
              worngDialgo(text: 'There is no user with this mail'));
      print(e);
    }
  }
}
