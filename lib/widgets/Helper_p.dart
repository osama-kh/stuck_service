import 'dart:io';
import 'dart:math';
//--no-sound-null-safety
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stuck_service/models/main_theme.dart';
import 'package:stuck_service/widgets/notifications_helper_panel.dart';
import 'package:stuck_service/widgets/side_drawer.dart';
import 'package:stuck_service/widgets/spinner.dart';
import 'BarIndicator.dart';
import 'package:stuck_service/widgets/userPage.dart';
import 'package:intl/intl.dart';

class Helper_p extends StatefulWidget {
  final dataOfUser;
  Helper_p(this.dataOfUser);

  @override
  State<Helper_p> createState() => _Helper_pState();
}

//variabels
late GoogleMapController mapController;
late LatLng currentLocation = LatLng(32.109333, 34.855499);
late LatLng currentLocationHelp;
bool showSpinner = false;
bool mapCreated = false;
final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;
Set<Marker> waiting = {};
Map<dynamic, dynamic> waitingStucked = {};
final GlobalKey<ScaffoldState> _drawerscaffoldkey =
    new GlobalKey<ScaffoldState>();
String status = 'offline';
String lastonline = '';
Color _colorStatus = Colors.red;
String imageurl = 'null';

class _Helper_pState extends State<Helper_p> {
  final panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getWaitingStucked();
  }

  late BitmapDescriptor customMarker;

  Future<void> setCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/stuckedLogo.png');
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      showSpinner = true;
    });
    LocationPermission permission = await Geolocator.checkPermission();
    User? user = await _auth.currentUser;
    final events =
        await _firestore.collection('helperStatus').doc(user?.email).get();
    status = events.data()!['status'];
    status == 'offline'
        ? _colorStatus = Colors.red
        : _colorStatus = Colors.green;
    status == 'offline' ? lastOnline() : lastonline = 'online';
    await getImageData();

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
      await _getCurrentLocationToHelp();
    }
  }

  Future<void> getWaitingStucked() async {
    setState(() {
      showSpinner = true;
    });
    setCustomMarker();
    User? user = _auth.currentUser;
    waitingStucked = {};
    await for (var snapshot in _firestore
        .collection('notifications')
        .where("receiver", isEqualTo: user!.email)
        .where("status", isEqualTo: 'waiting')
        .snapshots()) {
      final List<QueryDocumentSnapshot> documents = snapshot.docs;
      for (QueryDocumentSnapshot document in documents) {
        waitingStucked.putIfAbsent(document.id, () => document.data());
      }
      waitingStuckedMarker();
    }

    setState(() {
      showSpinner = false;
    });
  }

  Future<void> _getCurrentLocationToHelp() async {
    setState(() {
      showSpinner = true;
    });
    User? user = await _auth.currentUser;
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
      currentLocationHelp = LatLng(position.latitude, position.longitude);
      await _firestore.collection("positionsHelper").doc(user?.email).set(
          {'latitude': position.latitude, 'longitude': position.longitude});
      setState(() {
        showSpinner = false;
      });
    }
  }

  Future<void> waitingStuckedMarker() async {
    setState(() {
      showSpinner = true;
    });
    waiting = {};
    await _getCurrentLocation();
    waiting.add(Marker(
      markerId: MarkerId('current_location'),
      position: currentLocation,
      infoWindow: InfoWindow(title: 'Current Location'),
    ));
    for (var key in waitingStucked.keys) {
      waiting.add(Marker(
        markerId: MarkerId(waitingStucked[key]["senderFullname"]),
        position: LatLng((waitingStucked[key]["senderlatitude"]),
            (waitingStucked[key]["senderlongitude"])),
        icon: customMarker,
        infoWindow: InfoWindow(
          title: waitingStucked[key]["senderFullname"],
          snippet: 'Marker Description',
          onTap: () {},
        ),
      ));
    }

    setState(() {
      showSpinner = false;
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          title: Row(
            children: [
              Text('Change status'),
              Flexible(
                  child: SizedBox(
                width: double.infinity,
              )),
              Text(
                status,
                style: TextStyle(
                    fontSize: 12,
                    color: status == 'online' ? Colors.green : Colors.red),
              ),
              SizedBox(
                width: 15,
              )
            ],
          ),
          titlePadding: EdgeInsets.all(15),
          //content: Text('celect your status now'),
          actions: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    //side: BorderSide(color: Colors.green, width: 1.5),
                    fixedSize: Size(100, 30),
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    primary: status == 'online'
                        ? main_theme().get_blue_grey()
                        : Colors.green),
                child: Text('Online'),
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  _getCurrentLocationToHelp();
                  await onlineORoffline('online');
                  setState(() {
                    status = 'online';
                    _colorStatus = Colors.green;
                    lastonline = 'online';
                    showSpinner = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  //side: BorderSide(color: Colors.red, width: 1.5),
                  fixedSize: Size(100, 30),
                  primary: status == 'offline'
                      ? main_theme().get_blue_grey()
                      : Colors.red,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                child: Text('Offline'),
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  await onlineORoffline('offline');
                  setState(() {
                    status = 'offline';
                    _colorStatus = Colors.red;
                    lastOnline();
                    showSpinner = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ]),
          ],
        );
      },
    );
  }

  Future<void> onlineORoffline(String status) async {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}/${now.month}/${now.year}";
    String formattedTime = "${now.hour}:${now.minute}:${now.second}";
    User? user = await _auth.currentUser;
    await _firestore.collection('helperStatus').doc(user?.email).set({
      'status': status,
      'lastDate': formattedDate,
      'lastTime': formattedTime
    });
  }

  Future<void> lastOnline() async {
    lastonline = ' ';
    User? user = await _auth.currentUser;
    final data =
        await _firestore.collection('helperStatus').doc(user!.email).get();
    final lastTime = data.data();
    if (lastTime != null) {
      String lastOnlineString =
          lastTime['lastDate'] + ' ' + lastTime['lastTime'] + ' ' + 'AM';
      DateFormat inputFormat = DateFormat('dd/MM/yyyy hh:mm:ss a');
      DateTime lastOnline = inputFormat.parse(lastOnlineString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastOnline);
      setState(() {
        lastonline = "Last online ${_formatDuration(difference)} ago";
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return "${duration.inDays} days";
    } else if (duration.inHours > 0) {
      return "${duration.inHours} hours";
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes} minutes";
    } else {
      return "just now";
    }
  }

/////////////////////
  Future<void> getImageData() async {
    setState(() {
      showSpinner = true;
    });
    User? user = await _auth.currentUser;
    var email = user!.email;
    try {
      final Reference ref = _storage.ref().child('images/$email');
      imageurl = await ref.getDownloadURL();
    } catch (e) {
      print(e);
    }
    setState(() {
      showSpinner = false;
    });
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _drawerscaffoldkey,
          drawer: side_drawer(
              widget.dataOfUser, imageurl, lastonline, _auth, context),

          ///fixxxxx
          bottomNavigationBar: BottomAppBar(
            color: main_theme().get_white(),
            child: Row(
              children: [
                const SizedBox(height: 70),
                IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      status == 'offline'
                          ? lastOnline()
                          : lastonline = 'online';

                      //on drawer menu pressed
                      if (_drawerscaffoldkey.currentState!.isDrawerOpen) {
                        //if drawer is open, then close the drawer
                        Navigator.pop(context);
                      } else {
                        _drawerscaffoldkey.currentState!.openDrawer();
                        //if drawer is closed then open the drawer.
                      }
                    }),
                GetStatus(),
                IconButton(
                    icon: Icon(Icons.event_available_outlined),
                    onPressed: () async {
                      _showDialog();
                    }),
                Text(
                  lastonline,
                  style: TextStyle(fontSize: 10),
                ),
                Spacer(),
                Text("helper"),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {
                      lastOnline();
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
          body: SlidingUpPanel(
            controller: panelController,
            backdropEnabled: true,
            panelBuilder: (controller) => notifications_helper_panel(
              panelController: panelController,
              controller: controller,
              waitingStucked: waitingStucked,
            ),
            minHeight: 45,
            maxHeight: MediaQuery.of(context).size.height * 0.4,
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            parallaxEnabled: true,
            body: ModalProgressHUD(
              inAsyncCall: showSpinner,
              progressIndicator: ProgressWithIcon(),
              child: StreamGoogleMap(),
            ),
          ),
        ));
  }
}

class GetStatus extends StatelessWidget {
  const GetStatus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Do something when the button is tapped
      },
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _colorStatus,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class StreamGoogleMap extends StatelessWidget {
  StreamGoogleMap({
    Key? key,
  }) : super(key: key);
  _Helper_pState helper = _Helper_pState();
  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('notifications')
            .where("receiver", isEqualTo: user!.email)
            .where("status", isEqualTo: 'waiting')
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
            waitingStucked = {};
            final documents = snapshot.data?.docs;
            for (var document in documents!) {
              waitingStucked.putIfAbsent(document.id, () => document.data());
              helper.waitingStuckedMarker();
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
            markers: waiting,
          );
        });
  }
}
