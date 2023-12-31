import 'dart:async';

import 'package:flutter3_firestore_passenger/models/uber_drivers.dart';
import 'package:flutter3_firestore_passenger/screens/available_drivers.dart';
import 'package:flutter3_firestore_passenger/screens/choose_destination.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter3_firestore_passenger/providers/google_map_functions.dart';
import 'package:flutter3_firestore_passenger/providers/geofire_provider.dart';
import 'package:flutter3_firestore_passenger/main_variables/main_variables.dart';
import 'package:flutter3_firestore_passenger/providers/location_provider.dart';
import 'package:flutter3_firestore_passenger/main.dart';
import 'package:flutter3_firestore_passenger/models/nearest_drivers.dart';
import 'package:flutter3_firestore_passenger/models/direction_details_info.dart';
import 'package:flutter3_firestore_passenger/progress/progress_dialog.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/users.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";
  String userPhoto = "";
  String userPhone = "";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<nearestDrivers> onlineNearByAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;
  String driverRideStatus = "Driver is Coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus = "";
  bool requestPositionInfo = true;

  double? currentUserLat;
  double? currentUserLong;

  Users? currentUserInfo;

  // Set<Marker> markers = {};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  final _firestore = FirebaseFirestore.instance;
  late Geoflutterfire geo;
  late Stream<List<DocumentSnapshot>> stream;
  final radius = BehaviorSubject<double>.seeded(1.0);
  late final Stream<QuerySnapshot> _driverStream;

  uberDrivers? driverInfo;
  List<uberDrivers>? uberDriverList = [];

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    setState(() {
      currentUserLat = userCurrentPosition!.latitude;
      currentUserLong = userCurrentPosition!.longitude;
    });

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await GoogleMapFunctions.searchAddressForGeographicCoOrdinates(
            userCurrentPosition!, context);
    print("this is your addresss = " + humanReadableAddress);

    // userName = userModelCurrentInfo!.displayName!;
    // print(userName);
    // userEmail = userModelCurrentInfo!.email!;
    // print(userEmail);
    // userPhone = userModelCurrentInfo!.phone!;
    // print(userPhone);
    // userPhoto = userModelCurrentInfo!.photoURL!;
    // print(userPhoto);

    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(
        latitude: userCurrentPosition!.latitude,
        longitude: userCurrentPosition!.longitude);
    stream = radius.switchMap((rad) {
      print("rad");
      print(rad);

      final collectionReference = _firestore.collection('locations');

      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'position', strictMode: true);
    });

    stream.listen((List<DocumentSnapshot> documentList) {
      print("documentList");
      print(documentList);

      _updateMarkers(documentList);
    });
    //initializeGeoFireListener();

    //GoogleMapFunctions.readTripsKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();

    // Stream collectionStream =
    //     FirebaseFirestore.instance.collection('locations').snapshots();

    CollectionReference reference =
        FirebaseFirestore.instance.collection('locations');
    reference.snapshots().listen((querySnapshot) {
      markers.clear();
      locateUserPosition();
      querySnapshot.docChanges.forEach((change) {
        print("upgraded-stream");
        print(change);
        print('documentChanges ${change.doc.data()}');

        // Do something with change
      });
    });

    // collectionStream.listen((event) {
    //   print("event5000");
    //   print(event.toString());
    // });

    // collectionStream.listen((querySnapshot) {
    //   querySnapshot..forEach((change) {
    //     print("upgraded-stream");
    //     print(change);
    //     // Do something with change
    //   });
    // });

    checkIfLocationPermissionAllowed();
  }

  @override
  void dispose() {
    super.dispose();

    GeoFireProvider.geoFireDriver = [];
  }

  goToNearestDrivers(currentTaxiType) async {
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("deals").push();

    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    print(originLocation!.locationLatitude.toString());
    print(originLocation.locationLongitude.toString());

    print(destinationLocation!.locationLatitude.toString());
    print(destinationLocation.locationLongitude.toString());

    Map originLocationMap = {
      //"key": value,
      "latitude": originLocation.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //"key": value,
      "latitude": destinationLocation.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    var currentUser = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        //String deviceRegistrationToken = documentSnapshot.data()["token"];

        print("documentSnapshot.data");
        print(documentSnapshot.data());
        currentUserInfo = Users.fromDocument(documentSnapshot);

        Navigator.push(
            context,
            MaterialPageRoute(
                //builder: (c) => NearestDrivers(
                builder: (c) => AvailableDrivers(
                      originLocationLatitude:
                          originLocation.locationLatitude.toString(),
                      originLocationLongitude:
                          originLocation.locationLongitude.toString(),
                      destinationLocationLatitude:
                          destinationLocation.locationLatitude.toString(),
                      destinationLocationLongitude:
                          destinationLocation.locationLongitude.toString(),
                      userName: currentUserInfo!.displayName,
                      userPhone: currentUserInfo!.phone,
                      userEmail: currentUserInfo!.email,
                      userPhoto: currentUserInfo!.photoURL,
                      originAddress: originLocation.locationName,
                      destinationAddress: destinationLocation.locationName,
                      currentLatitude: currentUserLat,
                      currentLongitude: currentUserLong,
                      currentTaxiType: currentTaxiType,
                    )));

        // print("uberUser");
        // print(currentUserInfo);
      } else {
        print('Document does not exist on the database');
      }
    });
    // await FirebaseFirestore.instance
    //     .collection('locations')
    //     .get()
    //     .then((QuerySnapshot querySnapshot) {
    //   querySnapshot.docs.forEach((doc) {
    //     //  print(doc["title"]);

    //     print("locations");
    //     print(doc);

    //     setState(() {
    //       //_user = User.fromDocument(doc);

    //       driverInfo = uberDrivers.fromDocument(doc);

    //       uberDriverList!.add(driverInfo!);

    //       print("uberDriverList");
    //       print(uberDriverList);

    //       //_restaurant = User.Restaru
    //       //restaurants.insert(index, element)
    //     });

    //     //goToNearestDrivers();
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();

    return WillPopScope(
      onWillPop: () async {
        GeoFireProvider.geoFireDriver = [];
        return true;
      },
      child: Scaffold(
        key: sKey,
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLineSet,
              //markers: markersSet,
              //markers: markers,
              markers: Set<Marker>.of(markers.values),
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                locateUserPosition();
              },
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 20),
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedSize(
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              // color: Colors.redAccent.withOpacity(0.7),
                              color: Color(0xFFfd0011),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_city,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      Provider.of<AppInfo>(context)
                                                  .userPickUpLocation !=
                                              null
                                          ? (Provider.of<AppInfo>(context)
                                                      .userPickUpLocation!
                                                      .locationName!)
                                                  .substring(0, 24) +
                                              "..."
                                          : "not getting address",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              // color: Colors.redAccent.withOpacity(0.7),
                              color: Color(0xFFfd0011),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  var responseFromSearchScreen =
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (c) =>
                                                  ChooseDestination()));

                                  if (responseFromSearchScreen ==
                                      "obtainedDropoff") {
                                    setState(() {
                                      openNavigationDrawer = false;
                                    });

                                    //draw routes - draw polyline
                                    await drawPolyLineFromOriginToDestination();
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_searching,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        Provider.of<AppInfo>(context)
                                                    .userDropOffLocation !=
                                                null
                                            ? Provider.of<AppInfo>(context)
                                                .userDropOffLocation!
                                                .locationName!
                                            : "Choose your destination...",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [gradientButton(() {}, 'Search Arryvd Driver')],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMarker(double lat, double lng) {
    final id = MarkerId(lat.toString() + lng.toString());
    final _marker = Marker(
      markerId: id,
      position: LatLng(lat, lng),
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      icon: activeNearbyIcon!,
      infoWindow: InfoWindow(title: 'Taxi Driver', snippet: '$lat,$lng'),
    );
    setState(() {
      markers[id] = _marker;
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      print("document5555");
      print(document);
      Map<String, dynamic>? snapData = document.data() as Map<String, dynamic>?;
      final GeoPoint point = snapData!['position']['geopoint'];
      _addMarker(point.latitude, point.longitude);
    });
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Getting Direction Path...",
      ),
    );

    var directionDetailsInfo =
        await GoogleMapFunctions.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.red,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        width: 4,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  initializeGeoFireListener() async {
    final queryLocation =
        GeoPoint(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    GeoFirestore geoFirestore = GeoFirestore(firestore.collection('places'));

// creates a new query around [37.7832, -122.4056] with a radius of 0.6 kilometers
    final List<DocumentSnapshot> documents =
        await geoFirestore.getAtLocation(queryLocation, 100000);
    documents.forEach((document) {
      print("geofirestore info");
      print(document.data);
    });
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print("geo fire");
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          //whenever any driver become active/online
          case Geofire.onKeyEntered:
            nearestDrivers activeNearbyAvailableDriver = nearestDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireProvider.addActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDriver);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriversOnUsersMap();
            }
            break;

          //whenever any driver become non-active/offline
          case Geofire.onKeyExited:
            GeoFireProvider.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

          //whenever driver moves - update driver location
          case Geofire.onKeyMoved:
            nearestDrivers activeNearbyAvailableDriver = nearestDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireProvider.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

          //display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnUsersMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for (nearestDrivers eachDriver in GeoFireProvider.geoFireDriver) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver" + eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      setState(() {
        markersSet = driversMarkerSet;
      });
    });
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(1, 1));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  gradientButton(route, text) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        // color: Colors.redAccent.withOpacity(0.7),
        color: Color(0xFFfd0011),
      ),
      child: InkWell(
        onTap: () async {
          print("clicked");

          showDialog(
            context: context,
            builder: (BuildContext context) => ProgressDialog(
              message: "Searching arryvd driver...",
            ),
          );

          await FirebaseFirestore.instance
              .collection('locations')
              .get()
              .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              //  print(doc["title"]);

              print("locations");
              print(doc);

              setState(() {
                //_user = User.fromDocument(doc);

                driverInfo = uberDrivers.fromDocument(doc);

                uberDriverList!.add(driverInfo!);

                print("uberDriverList");
                print(uberDriverList);

                //_restaurant = User.Restaru
                //restaurants.insert(index, element)
              });

              //goToNearestDrivers();
            });
          });
          //await goToNearestDrivers();
          Timer(Duration(seconds: 2), () async {
            Navigator.pop(context);

            if (Provider.of<AppInfo>(context, listen: false)
                    .userDropOffLocation !=
                null) {
              await showModalBottomSheet(
                backgroundColor: Colors.orangeAccent.withOpacity(0.8),
                barrierColor: Colors.transparent,
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        await goToNearestDrivers("Elegant");
                      },
                      child: ListTile(
                        leading: Image(
                          image: AssetImage('images/Elegant.png'),
                        ),
                        title: Text(
                          'Elegant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          // '\$ ' + getFareAmountAccordingToVehicleType(index),
                          '\R ' +
                              (double.parse("5") *
                                          ((tripDirectionDetailsInfo!
                                                      .distance_value)! /
                                                  1000)
                                              .toDouble() +
                                      double.parse("2.5") *
                                          ((tripDirectionDetailsInfo!
                                                      .duration_value)! /
                                                  60)
                                              .toDouble())
                                  .toStringAsFixed(1),

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () async {
                        await goToNearestDrivers("Motorcycle");
                      },
                      child: ListTile(
                        leading: Image(
                          image: AssetImage('images/Simple.png'),
                        ),
                        title: Text(
                          'Simple',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          // '\$ ' + getFareAmountAccordingToVehicleType(index),
                          '\R ' +
                              (double.parse("3") *
                                          ((tripDirectionDetailsInfo!
                                                      .distance_value)! /
                                                  1000)
                                              .toDouble() +
                                      double.parse("1") *
                                          ((tripDirectionDetailsInfo!
                                                      .duration_value)! /
                                                  60)
                                              .toDouble())
                                  .toStringAsFixed(1),

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () async {
                        await goToNearestDrivers("Simple");
                      },
                      child: ListTile(
                        leading: Image(
                          image: AssetImage('images/Motorcycle.png'),
                        ),
                        title: Text(
                          'VIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          // '\$ ' + getFareAmountAccordingToVehicleType(index),
                          '\R ' +
                              (double.parse("7.5") *
                                          ((tripDirectionDetailsInfo!
                                                      .distance_value)! /
                                                  1000)
                                              .toDouble() +
                                      double.parse("1") *
                                          ((tripDirectionDetailsInfo!
                                                      .duration_value)! /
                                                  60)
                                              .toDouble())
                                  .toStringAsFixed(1),

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await goToNearestDrivers("Simple");
                      },
                      child: ListTile(
                        leading: Image(
                          image: AssetImage('images/Motorcycle.png'),
                        ),
                        title: Text(
                          'Hatch',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          // '\$ ' + getFareAmountAccordingToVehicleType(index),
                          '\R ' +
                              (double.parse("2.5") *
                                  ((tripDirectionDetailsInfo!
                                      .distance_value)! /
                                      1000)
                                      .toDouble() +
                                  double.parse("1") *
                                      ((tripDirectionDetailsInfo!
                                          .duration_value)! /
                                          60)
                                          .toDouble())
                                  .toStringAsFixed(1),

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await goToNearestDrivers("Elegant");
                        await goToNearestDrivers("Simple");
                        await goToNearestDrivers("Motorcycle");

                      },
                      child: ListTile(
                        leading: Image(
                          image: AssetImage('images/Motorcycle.png'),
                        ),
                        title: Text(
                          'Sedan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          // '\$ ' + getFareAmountAccordingToVehicleType(index),
                          '\R ' +
                              (double.parse("1.5") *
                                  ((tripDirectionDetailsInfo!
                                      .distance_value)! /
                                      1000)
                                      .toDouble() +
                                  double.parse("0.1") *
                                      ((tripDirectionDetailsInfo!
                                          .duration_value)! /
                                          60)
                                          .toDouble())
                                  .toStringAsFixed(1),

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // FlutterLogo(size: 120),
                    // FlutterLogo(size: 120),
                    // FlutterLogo(size: 120),
                    // FlutterLogo(size: 120),
                    // ElevatedButton(
                    //   child: Text('Close'),
                    //   onPressed: () => Navigator.pop(context),
                    // ),
                  ],
                ),
              );
            } else {
              await Fluttertoast.showToast(
                  msg: "Please select destination location");
            }

            // if (Provider.of<AppInfo>(context, listen: false)
            //         .userDropOffLocation !=
            //     null) {
            //   await goToNearestDrivers();
            // } else {
            //   await Fluttertoast.showToast(
            //       msg: "Please select destination location");
            // }
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //SizedBox(),

            Icon(
              Icons.share_location,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'bold', fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
