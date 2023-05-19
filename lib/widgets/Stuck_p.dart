import 'dart:convert';
import 'dart:io';
import 'dart:math';
//--no-sound-null-safety
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stuck_service/models/main_theme.dart';
import 'package:stuck_service/widgets/helper_info_card.dart';
import 'package:stuck_service/widgets/helper_info_card_panel.dart';
import 'package:stuck_service/widgets/side_drawer.dart';
import 'package:stuck_service/widgets/spinner.dart';
import 'package:stuck_service/widgets/userPage.dart';
import 'BarIndicator.dart';

import 'package:http/http.dart' as http;

enum SingingCharacter {
  Flat_tyre,
  Broken_battery,
  Out_of_Gaz_or_Electric,
  Over_Heating,
  Brakes,
  Engine,
  starter,
  Other
}

class Stuck_p extends StatefulWidget {
  final dataOfUser;
  Stuck_p(this.dataOfUser);

  @override
  State<Stuck_p> createState() => _Stuck_pState();
}

//variabels
late GoogleMapController mapController;
late LatLng currentLocation = LatLng(32.109333, 34.855499);
bool showSpinner = false;
bool mapCreated = false;
bool sos = false;
final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;
final _auth = FirebaseAuth.instance;
final GlobalKey<ScaffoldState> _drawerscaffoldkey =
    new GlobalKey<ScaffoldState>();

Map<dynamic, dynamic> Onlinehelper = {};
Map<dynamic, dynamic> Onlinehelperdata = {};
Map<dynamic, dynamic> OnlinehelperPosition = {};
Set<Marker> onlines = {};
Map<dynamic, String> UsersImagesUrls = {};
Map<dynamic, dynamic> distancefromOnlineHelper = {};
Map<dynamic, dynamic> helperTokens = {};

class _Stuck_pState extends State<Stuck_p> {
  // state variables
  var _messege_to_all_helpers_in_radius;
  final panelController = PanelController();
  @override
  void initState() {
    _getCurrentLocation();
    // set_value_of_singing_character();
    // notification(context);
    super.initState();
  }

  User? user = _auth.currentUser;
  double _currentSliderValue = 5;
  bool radius_flag = false;
  late BitmapDescriptor customMarker;
  Future<void> setCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/helperLogo.png');
  }

  Future<void> getStatusandPositionHelpers() async {
    setState(() {
      showSpinner = true;
    });
    setCustomMarker();
    Onlinehelper = {};
    Onlinehelperdata = {};
    OnlinehelperPosition = {};
    distancefromOnlineHelper = {};
    helperTokens = {};
    await for (var snapshot in _firestore
        .collection('helperStatus')
        .where("status", isEqualTo: 'online')
        .snapshots()) {
      final List<QueryDocumentSnapshot> documents = snapshot.docs;

      for (QueryDocumentSnapshot document in documents) {
        Onlinehelper.putIfAbsent(document.id, () => document.data());
        final eventsData =
            await _firestore.collection('userData').doc(document.id).get();
        if (eventsData != null) {
          Onlinehelperdata.putIfAbsent(document.id, () => eventsData.data());
        }
        final eventsPosition = await _firestore
            .collection('positionsHelper')
            .doc(document.id)
            .get();
        if (eventsPosition != null) {
          OnlinehelperPosition.putIfAbsent(
              document.id, () => eventsPosition.data());
          distancefromOnlineHelper.putIfAbsent(
              document.id,
              () => calculateDistance(
                  currentLocation,
                  LatLng((OnlinehelperPosition[document.id]["latitude"]),
                      (OnlinehelperPosition[document.id]["longitude"]))));
        }
        final token =
            await _firestore.collection('token').doc(document.id).get();
        if (token != null) {
          helperTokens.putIfAbsent(document.id, () => token.data());
        }
      }

      onlineHelper();
      GetstatusSOS();
      print(Onlinehelper);
      print(Onlinehelperdata);
      print(OnlinehelperPosition);
      print(distancefromOnlineHelper);
      setState(() {
        showSpinner = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      showSpinner = true;
    });
    await getImageData();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // The user has denied location permissions
        // Handle this situation as appropriate for your app
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // The user has permanently denied location permissions
      //    Ask the user to grant permissions from the app settings
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: 11,
            ),
          ),
        );

        showSpinner = false;
      });
      await getStatusandPositionHelpers();
    }
  }

///////////////////////
  Future<void> getImageData() async {
    setState(() {
      showSpinner = true;
    });

    try {
      final Reference ref = _storage.ref().child('images');
      final ListResult result = await ref.listAll();
      UsersImagesUrls = {};
      for (final Reference ref in result.items) {
        final String url = await ref.getDownloadURL();
        UsersImagesUrls.putIfAbsent(ref.name, () => url);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      showSpinner = false;
    });
  }

//////////////////////
  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6378137; // Earth's radius in meters
    double lat1Radians = start.latitude * (pi / 180);
    double lat2Radians = end.latitude * (pi / 180);
    double latDiffRadians = (end.latitude - start.latitude) * (pi / 180);
    double lngDiffRadians = (end.longitude - start.longitude) * (pi / 180);

    double a = sin(latDiffRadians / 2) * sin(latDiffRadians / 2) +
        cos(lat1Radians) *
            cos(lat2Radians) *
            sin(lngDiffRadians / 2) *
            sin(lngDiffRadians / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

// Define a function to show the dialog
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search filter'),
          content: Text('search radius'),
          actions: <Widget>[
            StatefulBuilder(
              builder: (context, setState) => Center(
                //Slider to demand the search radius of helpers
                child: Slider(
                  value: _currentSliderValue,
                  min: 5,
                  max: 30,
                  divisions: 5,
                  label: _currentSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                      radius_flag = true;
                    });
                  },
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () async {
                  // Perform some action

                  _getCurrentLocation();
                  Future.delayed(Duration(seconds: 2), () {
                    panelController.open();
                  });

                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]),
          ],
        );
      },
    );
  }

  Future<void> onlineHelper() async {
    setState(() {
      showSpinner = true;
    });
    onlines = {};
    onlines.add(Marker(
      markerId: MarkerId('current_location'),
      position: currentLocation,
      infoWindow: InfoWindow(title: 'Current Location'),
    ));
    for (var key in Onlinehelper.keys) {
      onlines.add(Marker(
        markerId: MarkerId(Onlinehelperdata[key]["Fullname"]),
        position: LatLng((OnlinehelperPosition[key]["latitude"]),
            (OnlinehelperPosition[key]["longitude"])),
        icon: customMarker,
        infoWindow: InfoWindow(
          title: Onlinehelperdata[key]["Fullname"],
          snippet: 'Marker Description',
          onTap: () {
            dataHelperDialog(key);
          },
        ),
      ));

      if (onlines == null) {
        //todo
      }
    }

    setState(() {
      showSpinner = false;
    });
  }

  Future<dynamic> dataHelperDialog(key) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment(0.0, 0.74),
          child: Container(
            margin: EdgeInsets.all(20),
            height: 70,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      blurRadius: 20,
                      offset: Offset.zero,
                      color: Colors.grey.withOpacity(0.5))
                ]),
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      width: 50,
                      height: 50,
                      child: ClipOval(
                        child: UsersImagesUrls[key] != null
                            ? CircleAvatar(
                                radius: MediaQuery.of(context).size.width * 0.3,
                                backgroundImage:
                                    NetworkImage(UsersImagesUrls[key]!),
                              )
                            : CircleAvatar(
                                radius: MediaQuery.of(context).size.width * 0.3,
                                backgroundColor: main_theme().get_blue_grey(),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(Onlinehelperdata[key]['Fullname'],
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 18)),
                            Text(
                                'Latitude: ${OnlinehelperPosition[key]['latitude'].toString()}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(
                                'Longitude: ${OnlinehelperPosition[key]['longitude'].toString()}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(
                                'Distance: ${(distancefromOnlineHelper[key] / 1000).toStringAsFixed(2)} km',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }

  SingingCharacter? _character = SingingCharacter.Broken_battery;
  void set_value_of_singing_character(value) {
    setState(() {
      _character = value;
    });
  }

  // ignore: non_constant_identifier_names

  bool other_problem_flag = false;
  Future<void> notification(context) {
    var size_box = MediaQuery.of(context).size.height * 0.4;
    var size_box1 = MediaQuery.of(context).size.height * 0.5;

    // Future.delayed(Duration.zero,(){});
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                title: Text(
                  "I need help",
                  style: TextStyle(fontSize: 18),
                ),
                content: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  height: other_problem_flag ? size_box1 : size_box,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            typeOfproblem("Broken battery - no Electricity",
                                SingingCharacter.Broken_battery, setState),
                            typeOfproblem(
                                "Out of Gaz/Electric",
                                SingingCharacter.Out_of_Gaz_or_Electric,
                                setState),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            typeOfproblem("Flat Tyre",
                                SingingCharacter.Flat_tyre, setState),
                            typeOfproblem("Over Heating",
                                SingingCharacter.Over_Heating, setState),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            typeOfproblem("Brakes is'nt responding",
                                SingingCharacter.Brakes, setState),
                            typeOfproblem("Engine Light Turned on",
                                SingingCharacter.Engine, setState),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            typeOfproblem("Car is'nt starting (Starter)",
                                SingingCharacter.starter, setState),
                            typeOfproblem(
                                "Other", SingingCharacter.Other, setState),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        other_problem_flag
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.62,
                                          child: TextField(
                                            maxLines: 3,
                                            keyboardType:
                                                TextInputType.multiline,
                                            onChanged: (value) {
                                              _messege_to_all_helpers_in_radius =
                                                  value;
                                            },
                                            decoration: const InputDecoration(
                                                hintText: "Problem Description",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12)))),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              )
                            : SizedBox(
                                width: 10,
                              ),
                        Row(
                          children: [
                            Flexible(
                                child: SizedBox(
                              width: double.infinity,
                            )),
                            ElevatedButton(
                              onPressed: () {
                                sendNotification(
                                    'messaging from ' + dataOfUser['Fullname'],
                                    'need help!',
                                    _messege_to_all_helpers_in_radius);

                                setState(() {
                                  sos = true;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text("Send"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      main_theme().get_blue_grey()),
                            ),
                            SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  GestureDetector typeOfproblem(
      String problemText, SingingCharacter? type, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (type == SingingCharacter.Other) {
            other_problem_flag = true;
          } else {
            other_problem_flag = false;
          }

          _character = type;
          _messege_to_all_helpers_in_radius = problemText;
        });
      },
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: _character == type
                  ? Color.fromARGB(255, 64, 122, 161)
                  : Color.fromARGB(255, 201, 201, 201),
              width: _character == type ? 3 : 1),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: SizedBox(
          width: 120,
          height: 40,
          child: Align(
            alignment: Alignment.center,
            child: Text(problemText,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Future<void> sendNotification(
      String title, String body, String description) async {
    await dotenv.load();
    for (var key in Onlinehelperdata.keys) {
      if (distancefromOnlineHelper[key] / 1000 <= _currentSliderValue &&
          helperTokens[key] != null) {
        final data = {
          'notification': {'title': title, 'body': body},
          'priority': 'high',
          'to': helperTokens[key]['token'],
        };
        final KEY = dotenv.env['NOTIFICATION_KEY'];
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'key=$KEY',
        };
        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: headers,
          body: json.encode(data),
        );
        if (response.statusCode == 200) {
          var idkey = user!.email! + ' ' + key;
          await _firestore.collection("notifications").doc(idkey).set({
            'status': 'waiting',
            'sender': user!.email,
            'senderFullname': dataOfUser['Fullname'],
            'senderPhone': dataOfUser['phoneNumber'],
            'senderlatitude': currentLocation.latitude,
            'senderlongitude': currentLocation.longitude,
            'senderImageUrl': UsersImagesUrls[user?.email],
            'noteDescription': description,
            'receiver': key
          });
          print('Notification sent');
        } else {
          print('Error sending notification');
        }
      }
    }
  }

  Future<void> CancelSOS() async {
    final notification = _firestore.collection('notifications');
    notification
        .where('sender', isEqualTo: user!.email)
        .get()
        .then((querySnapshot) {
      final batch = FirebaseFirestore.instance.batch();
      querySnapshot.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
      return batch.commit();
    }).then((value) {
      print("Documents deleted successfully");
    }).catchError((error) {
      print("Error deleting documents: $error");
    });
  }

  Future<void> GetstatusSOS() async {
    final notification = _firestore.collection('notifications');
    final x = notification
        .where('sender', isEqualTo: user!.email)
        .where('status', isEqualTo: 'waiting');
    final QuerySnapshot querySnapshot = await x.get();
    if (querySnapshot.size > 0) {
      setState(() {
        sos = true;
      });
    } else {
      setState(() {
        sos = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

///////////////////////////////////////////build///////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _drawerscaffoldkey,
        // drawer : to manage the profile and other sittings in the account
        drawer: side_drawer(widget.dataOfUser, UsersImagesUrls[user?.email],
            'online', _auth, context),

// the bottom bar that include the main map controller and search tools
        bottomNavigationBar: BottomAppBar(
          color: main_theme().get_white(),
          child: Row(
            children: [
              const SizedBox(height: 70),
              IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    print(UsersImagesUrls);
                    //on drawer menu pressed
                    if (_drawerscaffoldkey.currentState!.isDrawerOpen) {
                      //if drawer is open, then close the drawer
                      Navigator.pop(context);
                    } else {
                      _drawerscaffoldkey.currentState!.openDrawer();
                      //if drawer is closed then open the drawer.
                    }
                  }),
              sos
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //side: BorderSide(color: Colors.red, width: 1.5),
                        fixedSize: Size(75, 30),
                        primary: Colors.red,
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text('Cancel SOS'),
                      onPressed: () async {
                        await CancelSOS();
                        setState(() {
                          sos = false;
                        });
                      },
                    )
                  : Text(''),
              Spacer(),
              Text("stucked"),
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    _showDialog();
                    await mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: currentLocation,
                          zoom: 10,
                        ),
                      ),
                    );
                  }),
              IconButton(
                  icon: const Icon(Icons.location_searching_rounded),
                  onPressed: () async {
                    await _getCurrentLocation();
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: currentLocation,
                          zoom: 12,
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),

        // slide up panel to show the helpers withen the given radius
        body: SlidingUpPanel(
          controller: panelController,
          panelBuilder: (controller) => helper_info_card_panel(
              panelController: panelController,
              controller: controller,
              Onlinehelper: Onlinehelper,
              Onlinehelperdata: Onlinehelperdata,
              userImage: UsersImagesUrls,
              distances: distancefromOnlineHelper,
              distanceNeed: _currentSliderValue),
          // header: BarIndicator(),

          //backdropEnabled: true,
          minHeight: 45,
          maxHeight: MediaQuery.of(context).size.height * 0.4,
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          parallaxEnabled: true,

          // Google map main system
          body: Stack(
            children: [
              ModalProgressHUD(
                inAsyncCall: showSpinner,
                progressIndicator: ProgressWithIcon(),
                child: StatefulBuilder(
                  builder: (context, setState) => Center(
                    child: StreamGoogleMap(
                        currentSliderValue: _currentSliderValue),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  backgroundColor: main_theme().get_white(),
                  onPressed: () {
                    notification(context);
                  },
                  child: CircleAvatar(
                    radius: 150,
                    backgroundColor: main_theme().get_white(),
                    foregroundImage: AssetImage("assets/images/sos-p.png"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
    // ignore: dead_code
  }
}

class StreamGoogleMap extends StatelessWidget {
  StreamGoogleMap({
    Key? key,
    required double currentSliderValue,
  })  : _currentSliderValue = currentSliderValue,
        super(key: key);
  _Stuck_pState stucked = _Stuck_pState();
  final double _currentSliderValue;
  Future<void> getStatusandPositionHelpers(
      QueryDocumentSnapshot<Object?> document) async {
    final eventsData =
        await _firestore.collection('userData').doc(document.id).get();
    if (eventsData != null) {
      Onlinehelperdata.putIfAbsent(document.id, () => eventsData.data());
    }
    final eventsPosition =
        await _firestore.collection('positionsHelper').doc(document.id).get();
    if (eventsPosition != null) {
      OnlinehelperPosition.putIfAbsent(
          document.id, () => eventsPosition.data());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('helperStatus')
            .where("status", isEqualTo: 'online')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          if (snapshot.hasData) {
            Onlinehelper = {};
            Onlinehelperdata = {};
            OnlinehelperPosition = {};
            final documents = snapshot.data?.docs;
            for (var document in documents!) {
              Onlinehelper.putIfAbsent(document.id, () => document.data());
              getStatusandPositionHelpers(document);
              stucked.onlineHelper();
            }
          }
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 9,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: onlines,
            circles: Set<Circle>.of([
              //search radius
              //if (radius_flag) ...[
              Circle(
                  onTap: () {
                    print(_currentSliderValue);
                  },
                  center: currentLocation,
                  fillColor: Colors.blue.withOpacity(0.3),
                  strokeWidth: 3,
                  strokeColor: Colors.blue,
                  radius: _currentSliderValue * 1000,
                  circleId: CircleId(" ") //radius

                  ),
            ]),
          );
        });
  }
}
