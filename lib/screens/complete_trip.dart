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

class CompleteTrip extends StatefulWidget {
  String? orderId;
  String? driverId;
  CompleteTrip({Key? key, this.orderId, this.driverId}) : super(key: key);

  @override
  State<CompleteTrip> createState() => _CompleteTripState();
}

class _CompleteTripState extends State<CompleteTrip> {
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
  String? timeDate;
  String? commision;
  String? subTotalValue;

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

        double subTotal = double.parse(dealInfo2.totalPayment.toString()) -
            double.parse(dealInfo2.commision.toString());

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
          distance = distanceTraveledFareAmountPerKilometer.toString() + " km";
          duration = timeTraveledFareAmountPerMinute.toString() + " min";
          totalPayment = dealInfo2.totalPayment.toString() + "\R";
          timeDate = dealInfo2.time;
          commision = dealInfo2.commision.toString() + "\R";
          subTotalValue = subTotal.toString() + "\R";
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

  List<Item> time = <Item>[
    const Item('15%'),
    const Item('20%'),
    const Item('25%'),
    const Item('custom'),
  ];

  // final _value = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppbar(),
      body: _buildBody(),
      bottomNavigationBar: _bottomNav(),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.redAccent.shade100,
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'Order ID: ' + widget.orderId!,
        style: TextStyle(
            color: Colors.white, fontFamily: "semibold", fontSize: 16),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLocation(),
          // _buildBoldFont('order Summary', '7 items'),
          _buildItems(),
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
          Row(
            children: [
              Icon(
                Icons.location_city,
                size: 24,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startAddress ?? "not getting address",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: "semibold"),
                    ),
                    // Text(
                    //   'whitehouse, gujarat 20, India',
                    //   style: TextStyle(
                    //       color: Colors.black54,
                    //       fontSize: 12,
                    //       fontFamily: "medium"),
                    // )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_searching,
                size: 24,
                color: Colors.deepOrange,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      endAddress ?? "end address",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: "semibold"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.black12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: "semibold")),
              Row(
                children: [
                  Text(timeDate ?? "2022-05-31",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontFamily: "medium")),
                  SizedBox(width: 5),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.black12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('Deliver Options',
          //         style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 14,
          //             fontFamily: "semibold")),
          //     Row(
          //       children: [
          //         Text('Leave at Front door',
          //             style: TextStyle(
          //                 color: Colors.black54,
          //                 fontSize: 12,
          //                 fontFamily: "medium")),
          //         SizedBox(width: 5),
          //         Icon(
          //           Icons.chevron_right,
          //           size: 18,
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          // Divider(thickness: 1, color: Colors.black12),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text('Instruction for Driver',
          //         style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 14,
          //             fontFamily: "semibold")),
          //     SizedBox(height: 5),
          //     // CupertinoTextField(
          //     //   placeholder: "Note for Driver",
          //     // ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildBoldFont(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.orangeAccent,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$text',
            style: TextStyle(
                color: Colors.black54, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            '$item',
            style: TextStyle(
                color: Colors.black54, fontSize: 14, fontFamily: 'medium'),
          ),
        ],
      ),
    );
  }

  Widget _buildItems() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Driver Information',
              style: TextStyle(
                  color: Colors.black, fontSize: 16, fontFamily: "semibold")),
          Divider(thickness: 1, color: Colors.black12),
          _buildCartAll(),
          // Divider(thickness: 1, color: Colors.black12),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text('Note',
          //         style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 14,
          //             fontFamily: "semibold")),
          //     SizedBox(height: 5),
          //     // CupertinoTextField(
          //     //   placeholder: "Add note for restaurant",
          //     // ),
          //   ],
          // ),
          // Divider(thickness: 1, color: Colors.black12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('Tip for Driver',
          //         style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 14,
          //             fontFamily: "semibold")),
          //     Text('Rs10.00',
          //         style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 14,
          //             fontFamily: "semibold")),
          //   ],
          // ),
          // chipList(),
          // time.map((e) {
          //     return _buildChip(
          //       e.name,
          //     );
          //   }).toList(),
          // Text(
          //     "The recommend tip is based on the delivery distance and effort. 100% of the tip goes to your driver.",
          //     style: TextStyle(color: Colors.black45, fontSize: 12)),
          Divider(thickness: 1, color: Colors.black12),
          _buildDistance('Distance', 'Rs120.00'),
          _buildDuration('Duration', '-Rs120.00'),
          _buildCommision('Commision fee', 'Rs4.00'),
          _buildTotal('Total', 'Rs5.00'),

          // _buildBill('Tip for Driver', 'Rs10.00'),
        ],
      ),
    );
  }

  chipList() {
    return Wrap(
      spacing: 10.0,
      children: time.map((e) {
        return _buildChip(
          e.text,
        );
      }).toList(),
    );
  }

  Widget _buildChip(name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ChoiceChip(
        label: Text(name),
        labelPadding: const EdgeInsets.symmetric(horizontal: 15),
        selected: _value == name,
        selectedColor: Colors.orangeAccent,
        onSelected: (bool value) {
          setState(() {
            _value = value ? name : null;
          });
        },
        backgroundColor: Colors.grey,
        labelStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBill(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            // "R"+text,
            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            distance ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildDistance(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            // "R"+text,

            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            distance ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            // "R"+text,

            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            duration ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            // "R"+text,

            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            subTotalValue ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommision(text, item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            // "R"+text,

            '$text',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'medium'),
          ),
          Text(
            commision ?? "0 km",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontFamily: 'bold'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartAll() {
    return Column(
      children: [
        _buildCartItem(),
        // Divider(thickness: 1, color: Colors.black12),
        // _buildCartItem(),
      ],
    );
  }

  Widget _buildCartItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // Image.network(
        //   driverPhoto ?? "images/logo.png",
        //   height: 25.0,
        //   width: 25.0,
        //   fit: BoxFit.fill,
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10),
        //   child: Text("2x"),
        // ),
        Expanded(
          child: _buildDriverInfo(),
          // child: Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       driverName ?? "driver Name",
          //       style: TextStyle(
          //           color: Colors.black, fontSize: 14, fontFamily: "semibold"),
          //     ),
          //     _buildCustomItem(),
          //   ],
          // ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Container(
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
                  child: Image.network(driverPhoto ?? 'images/Elegant.png'),
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
                              color: Colors.black),
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
                          color: Colors.black,
                          borderColor: Colors.white,
                          allowHalfRating: true,
                          starCount: 5,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          children: [
                            Text(
                              driverPhone ?? "Driver Phone",
                              style: TextStyle(
                                color: Colors.black,
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
                        color: Colors.black,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomItem() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: Text("Medium size",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black45, fontSize: 12)),
              ),
              Text("Edit",
                  style: TextStyle(
                      color: Colors.blue, fontSize: 12, fontFamily: "medium")),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                color: Colors.black54,
                child: const Text(" % ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: "semibold")),
              ),
              const SizedBox(width: 5),
              const Text("Note to Restauratn",
                  style: TextStyle(color: Colors.black45, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text("Rs300",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'semibold',
                          fontSize: 14)),
                  SizedBox(width: 10),
                  Text("Rs450",
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 90.0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                    color: Colors.black54, fontFamily: "medium", fontSize: 20),
              ),
              Row(
                children: [
                  // Text("Rs320",
                  //     style: TextStyle(color: Colors.black45, fontSize: 14)),
                  // SizedBox(width: 20),
                  Text(totalPayment ?? "0",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'semibold',
                          fontSize: 20)),
                  SizedBox(width: 10),
                ],
              ),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     Row(
          //       children: const [
          //         Icon(
          //           Icons.credit_card,
          //           size: 18,
          //         ),
          //         SizedBox(width: 5),
          //         Text(
          //           "Visa ***1220",
          //           style:
          //               TextStyle(color: Colors.black54, fontFamily: "medium"),
          //         ),
          //       ],
          //     ),
          //     const Text(
          //       "Promotion",
          //       style: TextStyle(color: Colors.black54, fontFamily: "medium"),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              child: const Text("Rate Trip",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "medium",
                  )),
              onPressed: () {
                _rateDriverBottomSheet(context);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => OrderStatus()));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rateDriverBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          late bool status = false;

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.7),
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
                                            rating: countRatingStars,
                                            color: Colors.white,
                                            borderColor: Colors.white,
                                            allowHalfRating: true,
                                            starCount: 5,
                                            size: 24,
                                            onRatingChanged:
                                                (valueOfStarsChoosed) {
                                              countRatingStars =
                                                  valueOfStarsChoosed;

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
                                                  titleStarsRating =
                                                      "Very Good";
                                                });
                                              }
                                              if (countRatingStars == 5) {
                                                setState(() {
                                                  titleStarsRating =
                                                      "Excellent";
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: 12.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              titleStarsRating,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                        ),
                      ),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white.withOpacity(1),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      print("clicked");
                                      FirebaseFirestore.instance
                                          .collection('drivers')
                                          .doc(widget.driverId)
                                          .get()
                                          .then((DocumentSnapshot
                                              documentSnapshot) async {
                                        if (documentSnapshot.exists) {
                                          var driverInfo =
                                              DriverRating.fromDocument(
                                                  documentSnapshot);

                                          print("driverInfoCounting");
                                          print(driverInfo);

                                          double pastRatings =
                                              double.parse(driverInfo.ratings!);
                                          double newAverageRatings =
                                              (pastRatings + countRatingStars) /
                                                  2;

                                          print("newAverageRatings");
                                          print(newAverageRatings);
                                          //rateDriverRef.set(newAverageRatings.toString());
                                          // var currentUser = FirebaseAuth.instance.currentUser;

                                          CollectionReference? drivers =
                                              FirebaseFirestore.instance
                                                  .collection('drivers');

                                          await drivers
                                              .doc(widget.driverId)
                                              .update({
                                            "ratings":
                                                newAverageRatings.toString()
                                          }).then((value) {
                                            print("User Added");
                                            Fluttertoast.showToast(
                                                msg: "Please Restart App Now");
                                            SystemNavigator.pop();
                                          }).catchError((error) => print(
                                                  "Failed to add user: $error"));
                                        }
                                      });

                                      //_settingModalBottomSheet(context);

                                      //_uberRideInfo(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Complete Trip",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'bold',
                                              fontSize: 20,
                                              color: Colors.deepOrange),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                      // gradientButton(() {}, driverRideStatus),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}

class Item {
  const Item(this.text);
  final String text;
}
