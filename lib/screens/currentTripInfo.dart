import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_firestore_passenger/models/track_driver.dart';
import 'package:flutter3_firestore_passenger/screens/complete_trip.dart';
import 'package:flutter3_firestore_passenger/screens/ride_summary.dart';
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
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:flutter3_firestore_passenger/providers/google_map_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/deal_info.dart';

//import 'ride_summary.dart';

class CurrentTripInfo extends StatefulWidget {
  String? dealId;
  String? timestamp;
  String? driverId;
  CurrentTripInfo({Key? key, this.dealId, this.timestamp, this.driverId})
      : super(key: key);

  @override
  State<CurrentTripInfo> createState() => _CurrentTripInfoState();
}

class _CurrentTripInfoState extends State<CurrentTripInfo> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
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

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<nearestDrivers> onlineNearByAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;
  DatabaseReference? driverLocationRequest;
  String driverRideStatus = "Show Trip Info";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus = "";
  bool requestPositionInfo = true;

  double? currentUserLat;
  double? currentUserLong;

  double? originLat;
  double? originLong;

  double? destLat;
  double? destLong;

  String? destName;
  String? originName;

  String? driverPhoto;
  String? driverName;
  String? driverPhone;
  String? driverType;
  String? driverRating;
  String? carBrand;
  String? carModel;
  String? carNumber;
  String? pincode;
  String? duration;
  String? distance;
  String? totalPayment;
  String? timestamp;
  String? driverId;

  bool _isTripInfo = true;
  bool _isPaymentInfo = false;

  Position? onlineDriverCurrentPosition;

  var _value;

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

    userName = userModelCurrentInfo!.displayName!;
    print("userName");
    print(userName);
    userEmail = userModelCurrentInfo!.email!;
    print("userEmail");
    print(userEmail);
  }

  @override
  void initState() {
    super.initState();

    print("widget.current.trip.id");
    print(widget.dealId);

    CollectionReference dealLists =
        FirebaseFirestore.instance.collection('deals');
    dealLists.doc(widget.driverId).snapshots().listen((querySnapshot) {
      print("querySnapshotData");
      var dealInfo = DealInfo.fromDocument(querySnapshot);

      if (dealInfo.status == "arrived") {
        Fluttertoast.showToast(msg: "Driver arrived at your position");
      }

      if (dealInfo.status == "ontrip") {
        Fluttertoast.showToast(msg: "Driver started your trip");
      }

      if (dealInfo.status == "ended") {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => RideSummary(
        //             orderId: dealInfo.timestamp, driverId: driverId)));

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompleteTrip(
                    orderId: dealInfo.timestamp, driverId: driverId)));
        Fluttertoast.showToast(msg: "Driver finished your trip");
      }
    });

    var currentUser = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance
        .collection('deals')
        .doc(widget.driverId)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        //String deviceRegistrationToken = documentSnapshot.data()["token"];

        print("documentSnapshot.data");
        print(documentSnapshot.data());

        var dealInfo2 = DealInfo.fromDocument(documentSnapshot);

        double timeTraveledFareAmountPerMinute =
            (double.parse(dealInfo2.duration!) / 60).truncate().toDouble();
        double distanceTraveledFareAmountPerKilometer =
            (double.parse(dealInfo2.distance!) / 1000).truncate().toDouble();

        await drawPolyLineFromOriginToDestination(
            dealInfo2.originLatitude ?? '',
            dealInfo2.originLongitude ?? '',
            dealInfo2.destinationLatitude ?? '',
            dealInfo2.destinationLongitude ?? '',
            dealInfo2.originAddress ?? '',
            dealInfo2.destinationAddress ?? '');

        setState(() {
          driverName = dealInfo2.driverName;
          driverPhoto = dealInfo2.driverPhoto;
          driverRating = dealInfo2.driverRating;
          distance = distanceTraveledFareAmountPerKilometer.toString();
          duration = timeTraveledFareAmountPerMinute.toString();
          totalPayment = dealInfo2.totalPayment! + '\R';
          pincode = dealInfo2.pincode;
          timestamp = dealInfo2.timestamp;
          driverId = dealInfo2.driverId;
        });

        //currentUserInfo = Users.fromDocument(documentSnapshot);
      } else {
        Fluttertoast.showToast(msg: "This driver do not exist. Try again.");
      }
    });

    // CollectionReference reference =
    //     FirebaseFirestore.instance.collection('deals');

    // reference.doc(widget.driverId).snapshots().listen((querySnapshot) {
    //   print("querySnapshotData");

    //   // var dealInfo = DealInfo.fromDocument(querySnapshot);

    //   // if (dealInfo.status == "arrived") {
    //   //   print("arrived");

    //   //   Fluttertoast.showToast(msg: "Driver started your trip");

    //   //   // Navigator.push(
    //   //   //     context,
    //   //   //     MaterialPageRoute(
    //   //   //         builder: (context) => CurrentTripInfo(
    //   //   //               dealId: dealInfo.driverId,
    //   //   //               timestamp: dealInfo.timestamp,
    //   //   //               driverId: dealInfo.driverId,
    //   //   //             )));
    //   // }
    //   print(querySnapshot.data());
    //   // markers.clear();
    //   // locateUserPosition();
    //   // querySnapshot.docChanges.forEach((change) {
    //   //   print("upgraded-stream");
    //   //   print(change);
    //   //   print('documentChanges ${change.doc.data()}');

    //   //   // Do something with change
    //   // });
    // }) as StreamSubscription<QuerySnapshot<Object?>>;

    // referenceRideRequest =
    //     FirebaseDatabase.instance.ref().child("deals").child(widget.dealId!);

    // //Response from a Driver
    // tripRideRequestInfoStreamSubscription =
    //     referenceRideRequest!.onValue.listen((eventSnap) async {
    //   if (eventSnap.snapshot.value == null) {
    //     return;
    //   }

    //   if ((eventSnap.snapshot.value as Map)["status"] != null) {
    //     userRideRequestStatus =
    //         (eventSnap.snapshot.value as Map)["status"].toString();
    //   }

    //   //status = accepted
    //   if (userRideRequestStatus == "accepted") {
    //     print("accepted");
    //   }

    //   if (userRideRequestStatus == "arrived") {
    //     //Navigator.pop(context);
    //     setState(() {
    //       _isTripInfo = false;
    //       _isPaymentInfo = true;

    //       driverRideStatus = "Show Trip Info";
    //     });

    //     Fluttertoast.showToast(msg: "Driver arrived at your Start Address");
    //   }

    //   //status = ontrip
    //   if (userRideRequestStatus == "ontrip") {
    //     setState(() {
    //       driverRideStatus = "Show Trip Info";
    //     });

    //     Fluttertoast.showToast(msg: "Driver started your trip");
    //   }

    //   if (userRideRequestStatus == "ended") {
    //     // Navigator.push(
    //     //     context, MaterialPageRoute(builder: (c) => RideSummary()));

    //     // print("assignedDriverId");
    //     // print((eventSnap.snapshot.value as Map)["timestamp"]);

    //     // String assignedDriverId =
    //     //     (eventSnap.snapshot.value as Map)["driverId"].toString();

    //     // print("assignedDriverId");
    //     // print(assignedDriverId);

    //     Fluttertoast.showToast(msg: "Driver finished your trip");

    //     // Navigator.push(
    //     //     context,
    //     //     MaterialPageRoute(
    //     //         builder: (context) =>
    //     //             RideSummary(orderId: timestamp, driverId: driverId)));
    //   }

    //   if (eventSnap.snapshot.value == null) {
    //     // Navigator.push(
    //     //     context, MaterialPageRoute(builder: (c) => RideSummary()));

    //     // print("assignedDriverId");
    //     // print((eventSnap.snapshot.value as Map)["timestamp"]);

    //     // String assignedDriverId =
    //     //     (eventSnap.snapshot.value as Map)["driverId"].toString();

    //     // print("assignedDriverId");
    //     // print(assignedDriverId);

    //     // Navigator.push(
    //     //     context,
    //     //     MaterialPageRoute(
    //     //         builder: (context) =>
    //     //             RideSummary(orderId: timestamp, driverId: driverId)));
    //   }
    // });

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("deals")
    //     .child(widget.dealId!)
    //     .once()
    //     .then((snap) async {
    //   if (snap.snapshot.value != null) {
    //     print("new info");
    //     print((snap.snapshot.value as Map)["origin"]["latitude"]);
    //     print((snap.snapshot.value as Map)["origin"]["latitude"]);
    //     print((snap.snapshot.value as Map)["destination"]["longitude"]);

    //     double timeTraveledFareAmountPerMinute =
    //         ((snap.snapshot.value as Map)["duration"] / 60)
    //             .truncate()
    //             .toDouble();
    //     double distanceTraveledFareAmountPerKilometer =
    //         ((snap.snapshot.value as Map)["distance"] / 1000)
    //             .truncate()
    //             .toDouble();
    //     await drawPolyLineFromOriginToDestination(
    //         (snap.snapshot.value! as Map)["origin"]["latitude"] ?? '',
    //         (snap.snapshot.value! as Map)["origin"]["longitude"] ?? '',
    //         (snap.snapshot.value! as Map)["destination"]["latitude"] ?? '',
    //         (snap.snapshot.value! as Map)["destination"]["longitude"] ?? '',
    //         (snap.snapshot.value! as Map)["originAddress"] ?? '',
    //         (snap.snapshot.value! as Map)["destinationAddress"] ?? '');

    //     setState(() async {
    //       driverPhoto = await (snap.snapshot.value as Map)["driverPhoto"];
    //       driverName = await (snap.snapshot.value as Map)["driverName"];
    //       driverPhone = await (snap.snapshot.value as Map)["driverPhone"];
    //       driverType = await (snap.snapshot.value as Map)["driverType"];
    //       driverRating = await (snap.snapshot.value as Map)["driverRating"];
    //       carBrand = await (snap.snapshot.value as Map)["carBrand"];
    //       carModel = await (snap.snapshot.value as Map)["carModel"];
    //       carNumber = await (snap.snapshot.value as Map)["carNumber"];
    //       pincode = await (snap.snapshot.value as Map)["pincode"];
    //       driverId = await (snap.snapshot.value as Map)["driverId"];
    //       timestamp =
    //           await (snap.snapshot.value as Map)["timestamp"].toString();
    //       duration = timeTraveledFareAmountPerMinute.toString() + " min";
    //       distance = distanceTraveledFareAmountPerKilometer.toString() + " km";
    //       totalPayment =
    //           await (snap.snapshot.value as Map)["totalPayment"] + "\$";
    //     });
    //   } else {
    //     Fluttertoast.showToast(msg: "This driver do not exist. Try again.");
    //   }
    // });
  }

  getDriversLocationUpdatesAtRealTime() {
    // LatLng oldLatLng = LatLng(0, 0);

    CollectionReference driverLocations =
        FirebaseFirestore.instance.collection('driverLocations');
    driverLocations.doc(widget.driverId).snapshots().listen((querySnapshot) {
      print("querySnapshotData");
      var trackDriver = TrackDriver.fromDocument(querySnapshot);

      LatLng latLngLiveDriverPosition = LatLng(
        double.parse(trackDriver.latitude!),
        double.parse(trackDriver.longitude!),
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: activeNearbyIcon!,
        infoWindow: const InfoWindow(title: "That is your Driver Position"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
        newGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");
        markersSet.add(animatingMarker);
      });

      // if (dealInfo.status == "arrived") {
      //   Fluttertoast.showToast(msg: "Driver arrived at your position");
      // }

      // if (dealInfo.status == "ontrip") {
      //   Fluttertoast.showToast(msg: "Driver started your trip");
      // }

      // if (dealInfo.status == "ended") {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => RideSummary(
      //               orderId: dealInfo.timestamp, driverId: driverId)));
      //   Fluttertoast.showToast(msg: "Driver finished your trip");
      // }
    });

    // driverLocationRequest = FirebaseDatabase.instance
    //     .ref()
    //     .child("locations")
    //     .child(widget.dealId!)
    //     .child("driverLocation");

    // //Response from a Driver
    // tripRideRequestInfoStreamSubscription =
    //     driverLocationRequest!.onValue.listen((eventSnap) async {
    //   LatLng latLngLiveDriverPosition = LatLng(
    //     double.parse((eventSnap.snapshot.value as Map)["latitude"]),
    //     double.parse((eventSnap.snapshot.value as Map)["longitude"]),
    //   );

    //   Marker animatingMarker = Marker(
    //     markerId: const MarkerId("AnimatedMarker"),
    //     position: latLngLiveDriverPosition,
    //     icon: activeNearbyIcon!,
    //     infoWindow: const InfoWindow(title: "That is your Driver Position"),
    //   );

    //   setState(() {
    //     CameraPosition cameraPosition =
    //         CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
    //     newGoogleMapController!
    //         .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //     markersSet.removeWhere(
    //         (element) => element.markerId.value == "AnimatedMarker");
    //     markersSet.add(animatingMarker);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();

    return Scaffold(
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
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              locateUserPosition();

              getDriversLocationUpdatesAtRealTime();
            },
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 40, bottom: 20),
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.redAccent.shade100.withOpacity(0.8),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
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
                                  ],
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
                          color: Colors.redAccent.shade100.withOpacity(0.8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Provider.of<AppInfo>(context)
                                                  .userDropOffLocation !=
                                              null
                                          ? Provider.of<AppInfo>(context)
                                              .userDropOffLocation!
                                              .locationName!
                                          : "Where to go?",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                showBottomModal(),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.deepOrange.withOpacity(0.4),
                //     borderRadius: BorderRadius.circular(10),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.shade300,
                //         blurRadius: 20.0,
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Container(
                //             height: 50,
                //             width: 50,
                //             decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(5),
                //                 image: DecorationImage(
                //                     image: NetworkImage(
                //                         driverPhoto ?? 'images/Elegant.png'),
                //                     fit: BoxFit.cover)),
                //           ),
                //           Expanded(
                //             child: Padding(
                //               padding: EdgeInsets.only(left: 10),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     driverName ?? "Driver name",
                //                     style: TextStyle(
                //                         color: Colors.white,
                //                         fontFamily: 'semi-bold',
                //                         fontSize: 18),
                //                   ),
                //                   SmoothStarRating(
                //                     rating: double.parse(driverRating ?? "0"),
                //                     color: Colors.white,
                //                     borderColor: Colors.black,
                //                     allowHalfRating: true,
                //                     starCount: 5,
                //                     size: 15,
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Padding(
                //                 padding: const EdgeInsets.all(2.0),
                //                 child: Column(
                //                   children: [
                //                     Text(
                //                       'Distance',
                //                       style: TextStyle(color: Colors.white),
                //                     ),
                //                     Text(distance ?? "0 km",
                //                         style: TextStyle(
                //                           color: Colors.white,
                //                         )),
                //                   ],
                //                 ),
                //               ),
                //               Padding(
                //                 padding: const EdgeInsets.all(2.0),
                //                 child: Column(
                //                   children: [
                //                     Text(
                //                       'Duration',
                //                       style: TextStyle(color: Colors.white),
                //                     ),
                //                     Text(duration ?? "0",
                //                         style: TextStyle(
                //                           color: Colors.white,
                //                         )),
                //                   ],
                //                 ),
                //               ),
                //               Padding(
                //                 padding: const EdgeInsets.all(2.0),
                //                 child: Column(
                //                   children: [
                //                     Text(
                //                       'Total',
                //                       style: TextStyle(color: Colors.white),
                //                     ),
                //                     Text(totalPayment ?? "0",
                //                         style: TextStyle(
                //                           color: Colors.white,
                //                         )),
                //                   ],
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //       SizedBox(
                //         height: 25,
                //       ),
                //       gradientButton(() {}, driverRideStatus)
                //     ],
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget showBottomModal() {
    late bool status = false;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Today Available',
              //       style: TextStyle(fontFamily: 'bold', color: Colors.grey),
              //     ),
              //     RichText(
              //       text: TextSpan(
              //           text: '\$ 20',
              //           style:
              //               TextStyle(color: Colors.black, fontFamily: 'bold'),
              //           children: [
              //             TextSpan(
              //               text: '/Hour',
              //               style: TextStyle(
              //                   color: Colors.grey, fontFamily: 'regular'),
              //               // recognizer: new TapGestureRecognizer()..onTap = () => print('Tap Here onTap'),
              //             )
              //           ]),
              //     ),
              //   ],
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 5),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         '8:30 AM - 9:00 PM',
              //         style: TextStyle(color: Colors.black, fontFamily: 'bold'),
              //       ),
              //     ],
              //   ),
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Arrives in 15:20 Min',
              //       style: TextStyle(
              //           fontFamily: 'bold', color: Colors.orangeAccent),
              //     ),
              //     InkWell(
              //       onTap: () {
              //         // Navigator.push(context,
              //         //     MaterialPageRoute(builder: (context) => filterPage()));
              //       },
              //       child: Container(
              //         padding:
              //             EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.all(
              //             Radius.circular(10.0),
              //           ),
              //           color: Color(0xFFF15B3A),
              //         ),
              //         child: Center(
              //             child: Text(
              //           'Book Now',
              //           style:
              //               TextStyle(color: Colors.white, fontFamily: 'bold'),
              //         )),
              //       ),
              //     ),
              //   ],
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   child: Container(
              //     decoration: BoxDecoration(
              //         border: Border(bottom: BorderSide(color: Colors.grey))),
              //   ),
              // ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepOrange),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox.fromSize(
                          size: Size.fromRadius(40),
                          child: FittedBox(
                            //child: Image.asset('images/Elegant.png'),
                            child: Image.network(
                                driverPhoto ?? 'images/Elegant.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    driverName ?? "Driver name",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'bold',
                                        fontSize: 18,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: SmoothStarRating(
                                    rating: double.parse(driverRating ?? "0"),
                                    color: Colors.white,
                                    borderColor: Colors.deepOrange,
                                    allowHalfRating: true,
                                    starCount: 5,
                                    size: 15,
                                  ),
                                ),
                                // Row(
                                //   children: [
                                //     Icon(
                                //       Icons.chat,
                                //       color: Colors.orangeAccent,
                                //     ),
                                //     SizedBox(
                                //       width: 10,
                                //     ),
                                //     Icon(
                                //       Icons.call,
                                //       color: Colors.orangeAccent,
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Duration",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        duration ?? "0",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        "min",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Distance",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        distance ?? "0 km",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        " km",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Chip(
                            shadowColor: Colors.redAccent.shade100,
                            backgroundColor: Colors.redAccent.shade100,
                            label: Text(totalPayment ?? "0",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              gradientButton(() {}, driverRideStatus),
            ],
          ),
        ),
      ),
    );
  }

  gradientButton(route, text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.deepOrangeAccent.withOpacity(0.8),
        ),
        child: InkWell(
          onTap: () {
            print("clicked");

            //_settingModalBottomSheet(context);

            _uberRideInfo(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'bold', fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> drawPolyLineFromOriginToDestination(
      originLat, originLong, destLat, destLong, originName, destName) async {
    print("draw polyline");
    print(originLat);
    print(originLong);
    print(destLat);
    print(destLong);
    print(originName);
    print(destName);

    var originLatLng =
        LatLng(double.parse(originLat), double.parse(originLong));
    var destinationLatLng =
        LatLng(double.parse(destLat), double.parse(destLong));

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
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
      infoWindow: InfoWindow(title: originName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destName, snippet: "Destination"),
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

  void _settingModalBottomSheet(context) {
    FirebaseFirestore.instance
        .collection('deals')
        .doc(widget.dealId!)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        //String deviceRegistrationToken = documentSnapshot.data()["token"];

        print("documentSnapshot.data");
        print(documentSnapshot.data());

        var dealInfo2 = DealInfo.fromDocument(documentSnapshot);

        double timeTraveledFareAmountPerMinute =
            (double.parse(dealInfo2.duration!) / 60).truncate().toDouble();
        double distanceTraveledFareAmountPerKilometer =
            (double.parse(dealInfo2.distance!) / 1000).truncate().toDouble();

        setState(() {
          driverName = dealInfo2.driverName;
          driverPhoto = dealInfo2.driverPhoto;
          driverPhone = dealInfo2.driverPhone;
          driverType = dealInfo2.driverType;
          driverRating = dealInfo2.driverRating;
          carBrand = dealInfo2.carBrand;
          carModel = dealInfo2.carModel;
          carNumber = dealInfo2.carNumber;
          pincode = dealInfo2.pincode;
          distance = distanceTraveledFareAmountPerKilometer.toString();
          duration = timeTraveledFareAmountPerMinute.toString();
          driverId = dealInfo2.driverId;
          timestamp = dealInfo2.timestamp;
          totalPayment = dealInfo2.totalPayment! + "\R";
        });

        //currentUserInfo = Users.fromDocument(documentSnapshot);
      }
    });

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("deals")
    //     .child(widget.dealId!)
    //     .once()
    //     .then((snap) async {
    //   if (snap.snapshot.value != null) {
    //     print("new info");
    //     print((snap.snapshot.value as Map)["origin"]["latitude"]);
    //     print((snap.snapshot.value as Map)["origin"]["latitude"]);
    //     print((snap.snapshot.value as Map)["destination"]["longitude"]);

    //     double timeTraveledFareAmountPerMinute =
    //         ((snap.snapshot.value as Map)["duration"] / 60)
    //             .truncate()
    //             .toDouble();
    //     double distanceTraveledFareAmountPerKilometer =
    //         ((snap.snapshot.value as Map)["distance"] / 1000)
    //             .truncate()
    //             .toDouble();

    //     setState(() async {
    //       driverPhoto = await (snap.snapshot.value as Map)["driverPhoto"];
    //       driverName = await (snap.snapshot.value as Map)["driverName"];
    //       driverPhone = await (snap.snapshot.value as Map)["driverPhone"];
    //       driverType = await (snap.snapshot.value as Map)["driverType"];
    //       driverRating = await (snap.snapshot.value as Map)["driverRating"];
    //       carBrand = await (snap.snapshot.value as Map)["carBrand"];
    //       carModel = await (snap.snapshot.value as Map)["carModel"];
    //       carNumber = await (snap.snapshot.value as Map)["carNumber"];
    //       pincode = await (snap.snapshot.value as Map)["pincode"];
    //       duration = timeTraveledFareAmountPerMinute.toString() + " min";
    //       distance = distanceTraveledFareAmountPerKilometer.toString() + " km";
    //       driverId = await (snap.snapshot.value as Map)["driverId"];
    //       timestamp =
    //           await (snap.snapshot.value as Map)["timestamp"].toString();
    //       totalPayment =
    //           await (snap.snapshot.value as Map)["totalPayment"] + "\$";
    //     });
    //   } else {
    //     Fluttertoast.showToast(msg: "This driver do not exist. Try again.");
    //     FirebaseDatabase.instance
    //         .ref()
    //         .child("deals")
    //         .child(widget.dealId!)
    //         .once()
    //         .then((snap) async {
    //       if (snap.snapshot.value == null) {}
    //     });
    //   }
    // });

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            height: 340,
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.9),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(driverPhoto!),
                  ),
                  SizedBox(height: 5),
                  Chip(
                    shadowColor: Colors.redAccent.shade100,
                    backgroundColor: Colors.redAccent.shade100,
                    label: Text(driverName ?? "",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: "bold")),
                  ),
                  SizedBox(height: 5),
                  SmoothStarRating(
                    rating: double.parse(driverRating ?? "0"),
                    color: Colors.white,
                    borderColor: Colors.redAccent.shade100,
                    allowHalfRating: true,
                    starCount: 5,
                    size: 25,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(Icons.star,
                            color: Colors.redAccent.shade100, size: 25),
                        const SizedBox(),
                        Expanded(
                          child: Chip(
                            shadowColor: Colors.redAccent.shade100,
                            backgroundColor: Colors.redAccent.shade100,
                            label: Text(
                              Provider.of<AppInfo>(context)
                                          .userPickUpLocation !=
                                      null
                                  ? (Provider.of<AppInfo>(context)
                                      .userPickUpLocation!
                                      .locationName!)
                                  : "not getting address",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(Icons.pin_drop,
                            color: Colors.redAccent.shade100, size: 25),
                        const SizedBox(),
                        Chip(
                          shadowColor: Colors.redAccent.shade100,
                          backgroundColor: Colors.redAccent.shade100,
                          label: Text(
                            Provider.of<AppInfo>(context).userDropOffLocation !=
                                    null
                                ? Provider.of<AppInfo>(context)
                                    .userDropOffLocation!
                                    .locationName!
                                : "Where to go?",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(),
                        SizedBox(),
                        SizedBox(),
                        Chip(
                          shadowColor: Colors.redAccent.shade100,
                          backgroundColor: Colors.redAccent.shade100,
                          label: Text("Pincode :",
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              )),
                        ),
                        Chip(
                          shadowColor: Colors.redAccent.shade100,
                          backgroundColor: Colors.redAccent.shade100,
                          label: Text(pincode ?? "",
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              )),
                        )
                      ]),
                  // _buildbtn(),
                ],
              ),
            ),
          );
        });
  }

  void _uberRideInfo(context) {
    FirebaseFirestore.instance
        .collection('deals')
        .doc(widget.dealId!)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        //String deviceRegistrationToken = documentSnapshot.data()["token"];

        print("documentSnapshot.data");
        print(documentSnapshot.data());

        var dealInfo2 = DealInfo.fromDocument(documentSnapshot);

        double timeTraveledFareAmountPerMinute =
            (double.parse(dealInfo2.duration!) / 60).truncate().toDouble();
        double distanceTraveledFareAmountPerKilometer =
            (double.parse(dealInfo2.distance!) / 1000).truncate().toDouble();

        setState(() {
          driverName = dealInfo2.driverName;
          driverPhoto = dealInfo2.driverPhoto;
          driverPhone = dealInfo2.driverPhone;
          driverType = dealInfo2.driverType;
          driverRating = dealInfo2.driverRating;
          carBrand = dealInfo2.carBrand;
          carModel = dealInfo2.carModel;
          carNumber = dealInfo2.carNumber;
          pincode = dealInfo2.pincode;
          distance = distanceTraveledFareAmountPerKilometer.toString();
          duration = timeTraveledFareAmountPerMinute.toString();
          driverId = dealInfo2.driverId;
          timestamp = dealInfo2.timestamp;
          totalPayment = dealInfo2.totalPayment! + "\R";
        });

        //currentUserInfo = Users.fromDocument(documentSnapshot);
      }
    });

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          late bool status = false;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.deepOrange),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: SizedBox.fromSize(
                                size: Size.fromRadius(40),
                                child: FittedBox(
                                  //child: Image.asset('images/Elegant.png'),
                                  child: Image.network(
                                      driverPhoto ?? 'images/Elegant.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          driverName ?? "Driver name",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: 'bold',
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: SmoothStarRating(
                                          rating:
                                              double.parse(driverRating ?? "0"),
                                          color: Colors.white,
                                          borderColor: Colors.deepOrange,
                                          allowHalfRating: true,
                                          starCount: 5,
                                          size: 15,
                                        ),
                                      ),
                                      // Row(
                                      //   children: [
                                      //     Icon(
                                      //       Icons.chat,
                                      //       color: Colors.orangeAccent,
                                      //     ),
                                      //     SizedBox(
                                      //       width: 10,
                                      //     ),
                                      //     Icon(
                                      //       Icons.call,
                                      //       color: Colors.orangeAccent,
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Duration",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              duration ?? "0",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              "min",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Distance",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              distance ?? "0 km",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              " km",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                Chip(
                                  shadowColor: Colors.redAccent.shade100,
                                  backgroundColor: Colors.redAccent.shade100,
                                  label: Text(totalPayment ?? "0",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Icon(Icons.star,
                              color: Colors.redAccent.shade100, size: 25),
                          const SizedBox(),
                          Expanded(
                            child: Text(
                              Provider.of<AppInfo>(context)
                                          .userPickUpLocation !=
                                      null
                                  ? (Provider.of<AppInfo>(context)
                                      .userPickUpLocation!
                                      .locationName!)
                                  : "not getting address",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Expanded(
                    //       child: Text(
                    //         Provider.of<AppInfo>(context).userPickUpLocation !=
                    //                 null
                    //             ? (Provider.of<AppInfo>(context)
                    //                 .userPickUpLocation!
                    //                 .locationName!)
                    //             : "not getting address",
                    //         style: const TextStyle(
                    //             color: Colors.white, fontSize: 14),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // Text(
                    //   Provider.of<AppInfo>(context).userDropOffLocation != null
                    //       ? Provider.of<AppInfo>(context)
                    //           .userDropOffLocation!
                    //           .locationName!
                    //       : "Where to go?",
                    //   style: const TextStyle(color: Colors.white, fontSize: 14),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 5),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         '8:30 AM - 9:00 PM',
                    //         style: TextStyle(
                    //             color: Colors.black, fontFamily: 'bold'),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Icon(Icons.pin_drop,
                              color: Colors.redAccent.shade100, size: 25),
                          const SizedBox(),
                          Expanded(
                            child: Text(
                              Provider.of<AppInfo>(context)
                                          .userDropOffLocation !=
                                      null
                                  ? Provider.of<AppInfo>(context)
                                      .userDropOffLocation!
                                      .locationName!
                                  : "Where to go?",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Expanded(
                    //       child: Text(
                    //         Provider.of<AppInfo>(context).userDropOffLocation !=
                    //                 null
                    //             ? Provider.of<AppInfo>(context)
                    //                 .userDropOffLocation!
                    //                 .locationName!
                    //             : "Where to go?",
                    //         style: const TextStyle(
                    //             color: Colors.white, fontSize: 14),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      //SizedBox(),
                      // SizedBox(),
                      // SizedBox(),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Chip(
                          shadowColor: Colors.redAccent.shade100,
                          backgroundColor: Colors.redAccent.shade100,
                          label: Text(
                            "Pincode :",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Chip(
                          shadowColor: Colors.redAccent.shade100,
                          backgroundColor: Colors.redAccent.shade100,
                          label: Text(pincode ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              )),
                        ),
                      )
                    ]),
                    // gradientButton(() {}, driverRideStatus),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
