import 'dart:async';
import 'dart:math';

//import 'package:flutter3_firestore_passenger/screens/currentTripInfo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_firestore_passenger/models/deal_info.dart';
import 'package:flutter3_firestore_passenger/models/token_driver.dart';
import 'package:flutter3_firestore_passenger/screens/currentTripInfo.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:flutter3_firestore_passenger/providers/google_map_functions.dart';
import 'package:flutter3_firestore_passenger/main_variables/main_variables.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter3_firestore_passenger/main_variables/main_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/uber_drivers.dart';
import '../providers/geofire_provider.dart';
import '../models/nearest_drivers.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailableDrivers extends StatefulWidget {
  String? originLocationLatitude;
  String? originLocationLongitude;
  String? destinationLocationLatitude;
  String? destinationLocationLongitude;
  String? userName;
  String? userPhone;
  String? userEmail;
  String? userPhoto;
  String? originAddress;
  String? destinationAddress;
  double? currentLatitude;
  double? currentLongitude;
  String? currentTaxiType;

  //List<uberDrivers>? onlineNearByAvailable = [];

  AvailableDrivers({
    Key? key,
    this.originLocationLatitude,
    this.originLocationLongitude,
    this.destinationLocationLatitude,
    this.destinationLocationLongitude,
    this.userName,
    this.userPhone,
    this.userEmail,
    this.userPhoto,
    this.originAddress,
    this.destinationAddress,
    this.currentLatitude,
    this.currentLongitude,
    this.currentTaxiType,
    //this.onlineNearByAvailable,
  }) : super(key: key);

  @override
  State<AvailableDrivers> createState() => _AvailableDriversState();
}

class _AvailableDriversState extends State<AvailableDrivers> {
  String fareAmount = "";
  String commissionFee = "";
  double commissionPercent = 0;

  bool activeNearbyDriverKeysLoaded = false;

  List<uberDrivers> onlineNearByAvailableDriversList = [];
  List driversList = [];

  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;
  String userRideRequestStatus = "";
  DatabaseReference? referenceRideRequest;

  late final Stream<QuerySnapshot> _locationStream;

  // final Stream<QuerySnapshot> _locationStream =
  //     FirebaseFirestore.instance.collection('locations').snapshots();

  @override
  void initState() {
    super.initState();

    print("widget.currentLatitude");
    print(widget.currentLatitude);
    print(widget.currentLongitude);

    print("widget.currentTaxiType");
    print(widget.currentTaxiType);

    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print(currentUser.uid);

      // setState(() {
      //   //_user = User.fromDocument(doc);
      //   _userId = currentUser.uid;
      // });
    }

    setState(() {
      _locationStream = FirebaseFirestore.instance
          .collection('locations')
          .where('carType', isEqualTo: widget.currentTaxiType)
          .snapshots();
    });

    // print("widget.onlineNearByAvailable");
    // print(widget.onlineNearByAvailable);

    //onlineNearByAvailableDriversList = widget.onlineNearByAvailable!;

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("commision")
    //     .once()
    //     .then((snap) async {
    //   if (snap.snapshot.value != null) {
    //     double percent = (snap.snapshot.value as Map)["percent"].toDouble();

    //     setState(() {
    //       commissionPercent = percent;
    //     });
    //   }
    // });

    //searchNearestOnlineDrivers(widget.onlineNearByAvailable);
    //initializeGeoFireListener(widget.currentLatitude, widget.currentLongitude);
  }

  getFareAmountAccordingToVehicleType(int index) {
    //if (tripDirectionDetailsInfo != null) {
    // if (driversList[index]["carType"].toString() == "Simple") {
    //   FirebaseDatabase.instance
    //       .ref()
    //       .child("settings")
    //       .child("Simple")
    //       .once()
    //       .then((snap) async {
    //     if (snap.snapshot.value != null) {
    //       double price = (snap.snapshot.value as Map)["price"].toDouble();

    //       double priceTime =
    //           (snap.snapshot.value as Map)["timePrice"].toDouble();

    //       setState(() {
    //         fareAmount = (GoogleMapFunctions
    //                     .calculateFareAmountFromOriginToDestination(
    //                         tripDirectionDetailsInfo!, price, priceTime) *
    //                 2)
    //             .toStringAsFixed(1);
    //       });
    //     }
    //   });
    //   // fareAmount =
    //   //     (GoogleMapFunctions.calculateFareAmountFromOriginToDestination(
    //   //                 tripDirectionDetailsInfo!) /
    //   //             2)
    //   //         .toStringAsFixed(1);
    // }
    // if (driversList[index]["carType"].toString() ==
    //     "Elegant") //means executive type of car - more comfortable pro level
    // {
    //   FirebaseDatabase.instance
    //       .ref()
    //       .child("settings")
    //       .child("Elegant")
    //       .once()
    //       .then((snap) async {
    //     if (snap.snapshot.value != null) {
    //       double price = (snap.snapshot.value as Map)["price"].toDouble();

    //       double priceTime =
    //           (snap.snapshot.value as Map)["timePrice"].toDouble();

    //       print("price");
    //       print(price);
    //       print("priceTime");
    //       print(priceTime);

    //       setState(() {
    //         fareAmount = (GoogleMapFunctions
    //                     .calculateFareAmountFromOriginToDestination(
    //                         tripDirectionDetailsInfo!, price, priceTime) *
    //                 2)
    //             .toStringAsFixed(1);
    //       });
    //     }
    //   });
    // }
    // if (driversList[index]["carType"].toString() ==
    //     "Motorcycle") // non - executive car - comfortable
    // {
    //   FirebaseDatabase.instance
    //       .ref()
    //       .child("settings")
    //       .child("Motorcycle")
    //       .once()
    //       .then((snap) async {
    //     if (snap.snapshot.value != null) {
    //       double price = (snap.snapshot.value as Map)["price"].toDouble();

    //       double priceTime =
    //           (snap.snapshot.value as Map)["timePrice"].toDouble();

    //       setState(() {
    //         fareAmount = (GoogleMapFunctions
    //                     .calculateFareAmountFromOriginToDestination(
    //                         tripDirectionDetailsInfo!, price, priceTime) *
    //                 2)
    //             .toStringAsFixed(1);
    //       });
    //     }
    //   });
    // }
    //}
    return fareAmount;
  }

  searchNearestOnlineDrivers(onlineNearByAvailable) async {
    //no active driver available
    if (onlineNearByAvailable.length == 0) {
      //cancel/delete the RideRequest Information
      // referenceRideRequest!.remove();

      // setState(() {
      //   polyLineSet.clear();
      //   markersSet.clear();
      //   circlesSet.clear();
      //   pLineCoOrdinatesList.clear();
      // });

      Fluttertoast.showToast(
          msg:
              "No Online Nearest Driver Available. Search Again after some time, Restarting App Now.");

      // Future.delayed(const Duration(milliseconds: 4000), () {
      //   SystemNavigator.pop();
      // });

      return;
    }

    //active driver available
    await retrieveOnlineDriversInformation(onlineNearByAvailable);
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    //   DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    //   for (int i = 0; i < onlineNearestDriversList.length; i++) {
    //     await ref
    //         .child(onlineNearestDriversList[i].driverId.toString())
    //         .once()
    //         .then((dataSnapshot) {
    //       var driverKeyInfo = dataSnapshot.snapshot.value;

    //       //  dList.add(driverKeyInfo);

    //       if ((dataSnapshot.snapshot.value as Map)["carType"].toString() ==
    //           "Simple") {
    //         FirebaseDatabase.instance
    //             .ref()
    //             .child("settings")
    //             .child("Simple")
    //             .once()
    //             .then((snap) async {
    //           if (snap.snapshot.value != null) {
    //             double price = (snap.snapshot.value as Map)["price"].toDouble();

    //             double priceTime =
    //                 (snap.snapshot.value as Map)["timePrice"].toDouble();

    //             setState(() {
    //               fareAmount = (GoogleMapFunctions
    //                           .calculateFareAmountFromOriginToDestination(
    //                               tripDirectionDetailsInfo!, price, priceTime) *
    //                       2)
    //                   .toStringAsFixed(1);

    //               var commission = double.parse(fareAmount) / commissionPercent;

    //               print("commission");
    //               print(commission);

    //               (dataSnapshot.snapshot.value as Map)['fareAmount'] = fareAmount;
    //               (dataSnapshot.snapshot.value as Map)['commision'] =
    //                   commission.toStringAsFixed(1);
    //               driverKeyInfo = dataSnapshot.snapshot.value;

    //               print("driverKeyInfo2");
    //               print(driverKeyInfo);

    //               driversList.add(driverKeyInfo);
    //             });
    //             print("dListInfo");
    //             print(driversList);
    //             print("driversList.length");
    //             print(driversList.length);

    //             // setState(() {
    //             //   fareAmount = (GoogleMapFunctions
    //             //               .calculateFareAmountFromOriginToDestination(
    //             //                   tripDirectionDetailsInfo!, price, priceTime) *
    //             //           2)
    //             //       .toStringAsFixed(1);
    //             // });
    //           }
    //         });
    //         // fareAmount =
    //         //     (GoogleMapFunctions.calculateFareAmountFromOriginToDestination(
    //         //                 tripDirectionDetailsInfo!) /
    //         //             2)
    //         //         .toStringAsFixed(1);
    //       }
    //       if ((dataSnapshot.snapshot.value as Map)["carType"].toString() ==
    //           "Elegant") //means executive type of car - more comfortable pro level
    //       {
    //         FirebaseDatabase.instance
    //             .ref()
    //             .child("settings")
    //             .child("Elegant")
    //             .once()
    //             .then((snap) async {
    //           if (snap.snapshot.value != null) {
    //             double price = (snap.snapshot.value as Map)["price"].toDouble();

    //             double priceTime =
    //                 (snap.snapshot.value as Map)["timePrice"].toDouble();

    //             print("price");
    //             print(price);
    //             print("priceTime");
    //             print(priceTime);

    //             setState(() {
    //               fareAmount = (GoogleMapFunctions
    //                           .calculateFareAmountFromOriginToDestination(
    //                               tripDirectionDetailsInfo!, price, priceTime) *
    //                       2)
    //                   .toStringAsFixed(1);

    //               var commission = double.parse(fareAmount) / commissionPercent;

    //               print("commission");
    //               print(commission);

    //               (dataSnapshot.snapshot.value as Map)['fareAmount'] = fareAmount;
    //               (dataSnapshot.snapshot.value as Map)['commision'] =
    //                   commission.toStringAsFixed(1);
    //               driverKeyInfo = dataSnapshot.snapshot.value;

    //               print("driverKeyInfo2");
    //               print(driverKeyInfo);

    //               driversList.add(driverKeyInfo);
    //             });
    //             print("dListInfo");
    //             print(driversList);
    //             print("driversList.length");
    //             print(driversList.length);
    //           }
    //         });
    //       }
    //       if ((dataSnapshot.snapshot.value as Map)["carType"].toString() ==
    //           "Motorcycle") // non - executive car - comfortable
    //       {
    //         FirebaseDatabase.instance
    //             .ref()
    //             .child("settings")
    //             .child("Motorcycle")
    //             .once()
    //             .then((snap) async {
    //           if (snap.snapshot.value != null) {
    //             double price = (snap.snapshot.value as Map)["price"].toDouble();

    //             double priceTime =
    //                 (snap.snapshot.value as Map)["timePrice"].toDouble();

    //             setState(() {
    //               fareAmount = (GoogleMapFunctions
    //                           .calculateFareAmountFromOriginToDestination(
    //                               tripDirectionDetailsInfo!, price, priceTime) *
    //                       2)
    //                   .toStringAsFixed(1);

    //               var commission =
    //                   (double.parse(fareAmount) * commissionPercent) / 100;

    //               print("commission");
    //               print(commission);

    //               (dataSnapshot.snapshot.value as Map)['fareAmount'] = fareAmount;
    //               (dataSnapshot.snapshot.value as Map)['commision'] = commission;

    //               driverKeyInfo = dataSnapshot.snapshot.value;

    //               print("driverKeyInfo2");
    //               print(driverKeyInfo);

    //               driversList.add(driverKeyInfo);
    //             });
    //             print("dListInfo");
    //             print(driversList);
    //             print("driversList.length");
    //             print(driversList.length);
    //           }
    //         });
    //       }
    //     });
    //   }
    // }
  }

  sendNotificationToDriverNow(String chosenDriverId) {
    CollectionReference? drivers =
        FirebaseFirestore.instance.collection('drivers');

    // drivers
    //     .doc(chosenDriverId + "/newRideStatus")
    //     .set(
    //       chosenDriverId,
    //     )
    //     .then((value) {
    //   print("User Added");
    // }).catchError((error) => print("Failed to add user: $error"));
    //assign/SET rideRequestId to newRideStatus in
    // Drivers Parent node for that specific choosen driver
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(chosenDriverId)
    //     .child("newRideStatus")
    //     .set(chosenDriverId);

    FirebaseFirestore.instance
        .collection('drivers')
        .doc(chosenDriverId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        //String deviceRegistrationToken = documentSnapshot.data()["token"];

        var uberDriver = TokenDriver.fromDocument(documentSnapshot);

        print("uberDriver");
        print(uberDriver);

        print("chosenDriverId");
        print(chosenDriverId);

        //send Notification Now
        GoogleMapFunctions.sendNotificationToDriverNow(
          uberDriver.token!,
          chosenDriverId,
          context,
        );

        Fluttertoast.showToast(msg: "Notification sent Successfully.");
        //sendNotificationToDriverNow(data["driverId"]);
        // print('Document data: ${documentSnapshot.data()}');

        // setState(() {
        //   category =
        //       CategoryModel.fromDocument(documentSnapshot);

        //   print("user_details");
        //   print(category);

        //   title.text = category!.cat_id!;
        //   description.text = category!.cat_id!;

        //   _restaurantImage = category!.firebase_url;
        // });
      } else {
        print('Document does not exist on the database');
      }
    });

    //automate the push notification service
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(chosenDriverId)
    //     .child("token")
    //     .once()
    //     .then((snap) {
    //   if (snap.snapshot.value != null) {
    //     String deviceRegistrationToken = snap.snapshot.value.toString();

    //     //send Notification Now
    //     GoogleMapFunctions.sendNotificationToDriverNow(
    //       deviceRegistrationToken,
    //       chosenDriverId,
    //       context,
    //     );

    //     Fluttertoast.showToast(msg: "Notification sent Successfully.");
    //   } else {
    //     Fluttertoast.showToast(msg: "Please choose another driver.");
    //     return;
    //   }
    // });
  }

  buildNoContent() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.lightGreen.shade100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _locationStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildNoContent();
          }

          return SingleChildScrollView(child: Column(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Map originLocationMap = {
                          //"key": value,
                          "latitude": widget.originLocationLatitude,
                          "longitude": widget.originLocationLongitude,
                        };

                        Map destinationLocationMap = {
                          //"key": value,
                          "latitude": widget.destinationLocationLatitude,
                          "longitude": widget.destinationLocationLongitude,
                        };

                        var total = (double.parse(data["priceKm"]) *
                                    ((tripDirectionDetailsInfo!
                                                .distance_value)! /
                                            1000)
                                        .toDouble() +
                                double.parse(data["priceMin"]) *
                                    ((tripDirectionDetailsInfo!
                                                .duration_value)! /
                                            60)
                                        .toDouble())
                            .toStringAsFixed(1);

                        var commission = (((double.parse(data["priceKm"]) *
                                            ((tripDirectionDetailsInfo!
                                                        .distance_value)! /
                                                    1000)
                                                .toDouble() +
                                        double.parse(data["priceMin"]) *
                                            ((tripDirectionDetailsInfo!
                                                        .duration_value)! /
                                                    60)
                                                .toDouble()) *
                                    10) /
                                100)
                            .toStringAsFixed(1);

                        var currentUser_uid =
                            FirebaseAuth.instance.currentUser!.uid;

                        var rng = new Random();
                        var code = rng.nextInt(9000) + 999;
                        String pincode = code.toString();

                        Map userInformationMap = {
                          "origin": originLocationMap,
                          "destination": destinationLocationMap,
                          "time": DateTime.now().toString(),
                          "userName": widget.userName,
                          "userPhone": widget.userPhone,
                          "userEmail": widget.userEmail,
                          "userId": currentUser_uid,
                          "userPhoto": widget.userPhoto,
                          "originAddress": widget.originAddress,
                          "destinationAddress": widget.destinationAddress,
                          "driverId": data["driverId"],
                          "status": "waiting",
                          "driverName": data["driverName"],
                          "driverPhone": data["phone"],
                          "driverPhoto": data["driverPhoto"],
                          "driverType": data["carType"],
                          "driverRating": data["ratings"],
                          "carBrand": data["carBrand"],
                          "carModel": data["carModel"],
                          "carNumber": data["carNumber"],
                          "timestamp": ServerValue.timestamp,
                          "totalPayment": total,
                          "commision": commission,
                          "duration": tripDirectionDetailsInfo!.duration_value,
                          "distance": tripDirectionDetailsInfo!.distance_value,
                          "pincode": pincode,
                        };

                        print("userInformationMap");
                        print(userInformationMap);

                        var currentUser = FirebaseAuth.instance.currentUser;

                        CollectionReference? deals =
                            FirebaseFirestore.instance.collection('deals');

                        deals.doc(data['driverId']).set({
                          "originLatitude": widget.originLocationLatitude,
                          "originLongitude": widget.originLocationLongitude,
                          "destinationLatitude":
                              widget.destinationLocationLatitude,
                          "destinationLongitude":
                              widget.destinationLocationLongitude,
                          "time": DateTime.now().toString(),
                          "userName": widget.userName,
                          "userPhone": widget.userPhone,
                          "userEmail": widget.userEmail,
                          "userId": currentUser_uid,
                          "userPhoto": widget.userPhoto,
                          "originAddress": widget.originAddress,
                          "destinationAddress": widget.destinationAddress,
                          "driverId": data["driverId"],
                          "status": "waiting",
                          "driverName": data["driverName"],
                          "driverPhone": data["phone"],
                          "driverPhoto": data["driverPhoto"],
                          "driverType": data["carType"],
                          "driverRating": data["ratings"],
                          "carBrand": data["carBrand"],
                          "carModel": data["carModel"],
                          "carNumber": data["carNumber"],
                          //"timestamp": FieldValue.serverTimestamp(),
                          "timestamp":
                              Timestamp.now().microsecondsSinceEpoch.toString(),

                          "totalPayment": total,
                          "commision": commission,
                          "duration": tripDirectionDetailsInfo!.duration_value
                              .toString(),
                          "distance": tripDirectionDetailsInfo!.distance_value
                              .toString(),
                          "pincode": pincode,
                        }).then((value) {
                          print("User Added");
                        }).catchError(
                            (error) => print("Failed to add user: $error"));

                        FirebaseFirestore.instance
                            .collection('drivers')
                            .doc(data["driverId"])
                            .get()
                            .then((DocumentSnapshot documentSnapshot) {
                          if (documentSnapshot.exists) {
                            sendNotificationToDriverNow(data["driverId"]);

                            CollectionReference reference =
                                FirebaseFirestore.instance.collection('deals');

                            StreamSubscription<QuerySnapshot> streamSub =
                                reference
                                    .doc(data["driverId"])
                                    .snapshots()
                                    .listen((querySnapshot) {
                              print("querySnapshotData");

                              var dealInfo =
                                  DealInfo.fromDocument(querySnapshot);

                              if (dealInfo.status == "accepted") {
                                print("accepted");

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CurrentTripInfo(
                                              dealId: dealInfo.driverId,
                                              timestamp: dealInfo.timestamp,
                                              driverId: dealInfo.driverId,
                                            )));
                              }
                              print(querySnapshot.data());
                              // markers.clear();
                              // locateUserPosition();
                              // querySnapshot.docChanges.forEach((change) {
                              //   print("upgraded-stream");
                              //   print(change);
                              //   print('documentChanges ${change.doc.data()}');

                              //   // Do something with change
                              // });
                            }) as StreamSubscription<QuerySnapshot<Object?>>;
                            // print('Document data: ${documentSnapshot.data()}');

                            //streamSub.cancel();
                            // setState(() {
                            //   category =
                            //       CategoryModel.fromDocument(documentSnapshot);

                            //   print("user_details");
                            //   print(category);

                            //   title.text = category!.cat_id!;
                            //   description.text = category!.cat_id!;

                            //   _restaurantImage = category!.firebase_url;
                            // });
                          } else {
                            print('Document does not exist on the database');
                          }
                        });
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => Category(
                        //           res_id: document.id,
                        //           title: data['title'],
                        //           owner_id: data['user_id'])),
                        // );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              margin:
                                  EdgeInsets.only(left: 24, right: 24, top: 50),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    // '\$ ' + getFareAmountAccordingToVehicleType(index),
                                    '\R ' +
                                        (double.parse(data["priceKm"]) *
                                                    ((tripDirectionDetailsInfo!
                                                                .distance_value)! /
                                                            1000)
                                                        .toDouble() +
                                                double.parse(data["priceMin"]) *
                                                    ((tripDirectionDetailsInfo!
                                                                .duration_value)! /
                                                            60)
                                                        .toDouble())
                                            .toStringAsFixed(1),

                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SmoothStarRating(
                                    rating: data["ratings"] == null
                                        ? 0.0
                                        : double.parse(data["ratings"]),
                                    color: Colors.white,
                                    borderColor: Colors.white,
                                    allowHalfRating: true,
                                    starCount: 5,
                                    size: 25,
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Name",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            data["driverName"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Brand",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            data["carBrand"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Model",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            data["carModel"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Car No",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            data["carNumber"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: 40,
                              child: Image.asset(
                                "images/" + data["carType"].toString() + ".png",
                                height: 100,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ));
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.redAccent.shade100,
      elevation: 0,
      title: Text(
        'Available Car',
        style: TextStyle(color: Colors.white),
      ),
      // actions: [
      //   IconButton(
      //     icon: Icon(
      //       Icons.menu,
      //       color: Colors.white,
      //     ),
      //     onPressed: () {},
      //   )
      // ],
    );
  }
}
