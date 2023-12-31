import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_firestore_passenger/models/driver_rating.dart';
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

class RideSummary extends StatefulWidget {
  String? orderId;
  String? driverId;
  RideSummary({Key? key, this.orderId, this.driverId}) : super(key: key);

  @override
  State<RideSummary> createState() => _RideSummaryState();
}

class _RideSummaryState extends State<RideSummary> {
  var _value;

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

  String? startAddress;
  String? destinationAddress;
  String? endAddress;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
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
          driverRating = dealInfo2.driverRating;
          driverPhone = dealInfo2.driverPhone;
          driverType = dealInfo2.driverType;
          carBrand = dealInfo2.carBrand;
          carModel = dealInfo2.carModel;
          carNumber = dealInfo2.carNumber;
          pincode = dealInfo2.pincode;
          startAddress = dealInfo2.originAddress;
          endAddress = dealInfo2.destinationAddress;
          distance = distanceTraveledFareAmountPerKilometer.toString();
          duration = timeTraveledFareAmountPerMinute.toString();
          totalPayment = dealInfo2.totalPayment;
        });

        //currentUserInfo = Users.fromDocument(documentSnapshot);
      }
    });

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("orders")
    //     .child(widget.orderId!)
    //     .once()
    //     .then((snap) async {
    //   if (snap.snapshot.value != null) {
    //     double timeTraveledFareAmountPerMinute =
    //         await ((snap.snapshot.value as Map)["duration"] / 60)
    //             .truncate()
    //             .toDouble();
    //     double distanceTraveledFareAmountPerKilometer =
    //         await ((snap.snapshot.value as Map)["distance"] / 1000)
    //             .truncate()
    //             .toDouble();

    //     setState(() {
    //       driverPhoto = (snap.snapshot.value as Map)["driverPhoto"];
    //       driverName = (snap.snapshot.value as Map)["driverName"];
    //       driverPhone = (snap.snapshot.value as Map)["driverPhone"];
    //       driverType = (snap.snapshot.value as Map)["driverType"];
    //       driverRating = (snap.snapshot.value as Map)["driverRating"];
    //       carBrand = (snap.snapshot.value as Map)["carBrand"];
    //       carModel = (snap.snapshot.value as Map)["carModel"];
    //       carNumber = (snap.snapshot.value as Map)["carNumber"];
    //       pincode = (snap.snapshot.value as Map)["pincode"];
    //       startAddress = (snap.snapshot.value as Map)["originAddress"];
    //       endAddress = (snap.snapshot.value as Map)["destinationAddress"];
    //       duration = timeTraveledFareAmountPerMinute.toString() + " min";
    //       distance = distanceTraveledFareAmountPerKilometer.toString() + " km";
    //       totalPayment = (snap.snapshot.value as Map)["totalPayment"] + "\$";
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.redAccent.shade100,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ' + widget.orderId!,
              style: TextStyle(
                  color: Colors.white, fontFamily: "semibold", fontSize: 16),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildbtn(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
        child: Column(
      children: [
        _buildDriver(),
        _buildDivider(),
        _buildLocation(),
        _buildDivider(),
        _buildRideDetail(),
        _buildDivider(),
        _buildBill(),
        _buildDivider(),
      ],
    ));
  }

  Widget _buildBill() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Price",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'bold',
                      color: Colors.deepOrange)),
              Text(totalPayment ?? "0\R",
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'bold',
                      color: Colors.deepOrange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAddress(),
          SizedBox(height: 30),
          _buildDestination(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 18,
          color: Colors.deepOrange,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            // width: ,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startAddress ?? "not getting address",
                  style:
                      const TextStyle(color: Colors.deepOrange, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestination() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 18,
          color: Colors.deepOrange,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            // width: ,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endAddress ?? "end address",
                  style:
                      const TextStyle(color: Colors.deepOrange, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRideDetail() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text("Distance",
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 14,
                      fontFamily: "medium")),
              Text(distance ?? "0 km",
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 16,
                      fontFamily: "semibold")),
            ],
          ),
          Column(
            children: [
              Text("Duration",
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 14,
                      fontFamily: "medium")),
              Text(duration ?? "0 min",
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 16,
                      fontFamily: "semibold")),
            ],
          ),
          Column(
            children: [
              Text("Total",
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 14,
                      fontFamily: "medium")),
              Text(totalPayment ?? "0\R",
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 16,
                      fontFamily: "semibold")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriver() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(driverPhoto ?? "images/logo.png"),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(driverName ?? "driver Name",
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: "bold",
                          color: Colors.deepOrange)),
                  Column(
                    children: [
                      SmoothStarRating(
                        rating: countRatingStars,
                        allowHalfRating: false,
                        starCount: 5,
                        color: Colors.deepOrange,
                        borderColor: Colors.deepOrange,
                        size: 24,
                        onRatingChanged: (valueOfStarsChoosed) {
                          countRatingStars = valueOfStarsChoosed;

                          if (countRatingStars == 1) {
                            setState(() {
                              titleStarsRating = "Very Bad";
                            });
                          }
                          if (countRatingStars == 2) {
                            setState(() {
                              titleStarsRating = "Bad";
                            });
                          }
                          if (countRatingStars == 3) {
                            setState(() {
                              titleStarsRating = "Good";
                            });
                          }
                          if (countRatingStars == 4) {
                            setState(() {
                              titleStarsRating = "Very Good";
                            });
                          }
                          if (countRatingStars == 5) {
                            setState(() {
                              titleStarsRating = "Excellent";
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      Text(
                        titleStarsRating,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildbtn() {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        child: btnText("Rate Driver"),
        onPressed: () {
          FirebaseFirestore.instance
              .collection('drivers')
              .doc(widget.driverId)
              .get()
              .then((DocumentSnapshot documentSnapshot) async {
            if (documentSnapshot.exists) {
              var driverInfo = DriverRating.fromDocument(documentSnapshot);

              print("driverInfoCounting");
              print(driverInfo);

              double pastRatings = double.parse(driverInfo.ratings!);
              double newAverageRatings = (pastRatings + countRatingStars) / 2;

              print("newAverageRatings");
              print(newAverageRatings);
              //rateDriverRef.set(newAverageRatings.toString());
              // var currentUser = FirebaseAuth.instance.currentUser;

              CollectionReference? drivers =
                  FirebaseFirestore.instance.collection('drivers');

              await drivers.doc(widget.driverId).update(
                  {"ratings": newAverageRatings.toString()}).then((value) {
                print("User Added");
                Fluttertoast.showToast(msg: "Please Restart App Now");
                SystemNavigator.pop();
              }).catchError((error) => print("Failed to add user: $error"));
            }
          });

          // DatabaseReference rateDriverRef = FirebaseDatabase.instance
          //     .ref()
          //     .child("drivers")
          //     .child(widget.driverId!)
          //     .child("ratings");

          // rateDriverRef.once().then((snap) {
          //   if (snap.snapshot.value == null) {
          //     rateDriverRef.set(countRatingStars.toString());

          //     SystemNavigator.pop();
          //   } else {
          //     double pastRatings = double.parse(snap.snapshot.value.toString());
          //     double newAverageRatings = (pastRatings + countRatingStars) / 2;
          //     rateDriverRef.set(newAverageRatings.toString());

          //     SystemNavigator.pop();
          //   }

          //   Fluttertoast.showToast(msg: "Please Restart App Now");
          // });
        },
        style: btnStyle(),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 16,
      color: Color.fromARGB(255, 243, 243, 243),
    );
  }

  btnText(txt) {
    return Text(txt, style: TextStyle(fontSize: 16, fontFamily: 'semibold'));
  }

  btnStyle() {
    return ElevatedButton.styleFrom(
      primary: Colors.deepOrange,
      onPrimary: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
    );
  }
}
