import 'dart:async';

import 'package:flutter3_firestore_passenger/main_variables/main_variables.dart';
// import 'package:flutter3_firestore_passenger/screens/order_details.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_firestore_passenger/screens/order_details.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../providers/geofire_provider.dart';
import '../providers/location_provider.dart';
import '../models/new_trip_history.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders extends StatefulWidget {
  Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  String? _userId;
  late final Stream<QuerySnapshot> _orderStream;

  @override
  void initState() {
    super.initState();

    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print(currentUser.uid);

      setState(() {
        //_user = User.fromDocument(doc);
        _userId = currentUser.uid;
      });
    }

    setState(() {
      _orderStream = FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser?.uid)
          .snapshots();
    });

    print("widget.currentLatitude");
  }

  buildNoContent() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.lightGreen),
      ),
    );
  }

  shadowBox() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.deepOrange.shade200,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.deepOrange,
              blurRadius: 5.0,
              offset: Offset(0.0, 0.25))
        ]);
  }

  nameLabel() {
    return TextStyle(fontFamily: 'medium', fontSize: 15);
  }

  boldLabel() {
    return TextStyle(fontFamily: 'medium');
  }

  greyLabel() {
    return TextStyle(color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        // backgroundColor: Colors.redAccent.shade100,
        backgroundColor: Color(0xFFfd0011),
        title: Text(
          "My Orders",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        // actions: <Widget>[
        //   InkWell(
        //     onTap: () {
        //       //Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(_cartItems)));
        //     },

        //     child: Padding(
        //       padding: const EdgeInsets.all(10.0),
        //       child: Container(
        //         height: 150,
        //         width: 30,
        //         child: Stack(
        //           children: <Widget>[
        //             IconButton(
        //               iconSize: 30,
        //               icon: Icon(
        //                 Icons.add_shopping_cart,
        //                 color: Colors.white,
        //               ),
        //               onPressed: () {
        //                 // Navigator.push(
        //                 //     context,
        //                 //     MaterialPageRoute(
        //                 //         builder: (context) => CartScreen()));
        //               }, //onpressed
        //             ), //iconbutton
        //           ], //children
        //         ), //stack
        //       ), //wcontainer
        //     ), //padding
        //   ), //inkwell
        // ], //widget
      ), //appBar
      body: StreamBuilder<QuerySnapshot>(
        stream: _orderStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildNoContent();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OrderDetails(orderId: data['timestamp'])));
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    // color: Colors.orangeAccent.withOpacity(0.7),
                    padding: const EdgeInsets.all(10.0),
                    //margin: const EdgeInsets.only(bottom: 10),
                    decoration: shadowBox(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(thickness: 1, color: Colors.black12),
                        Chip(
                          backgroundColor: Colors.deepOrange.shade300,
                          label: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'ID : ',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "bold",
                                          color: Colors.black),
                                    ),
                                    Text('Total: ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontFamily: "medium")),
                                  ],
                                ),
                              )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  InkWell(
                                    child: Text('${data['timestamp']}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "semibold",
                                          fontSize: 14,
                                        )),
                                  ),
                                  Row(
                                    children: [
                                      Text('${data['totalPayment']}\R',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'semibold',
                                              fontSize: 14)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Divider(thickness: 1, color: Colors.black12),
                        // Container(
                        //   color: Colors.orangeAccent,
                        //   padding:
                        //       EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        //   margin: EdgeInsets.symmetric(vertical: 10),
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: Column(
                        //           children: const [
                        //             Text("3 miles",
                        //                 style: TextStyle(
                        //                     color: Colors.black,
                        //                     fontSize: 12,
                        //                     fontFamily: "semibold")),
                        //             Text("Distance",
                        //                 style: TextStyle(
                        //                     color: Colors.black45,
                        //                     fontSize: 12,
                        //                     fontFamily: "medium")),
                        //           ],
                        //         ),
                        //       ),
                        //       Text("|",
                        //           style: TextStyle(
                        //               color: Colors.black12, fontSize: 24)),
                        //       Expanded(
                        //         child: Column(
                        //           children: const [
                        //             Text("15 mins",
                        //                 style: TextStyle(
                        //                     color: Colors.black,
                        //                     fontSize: 12,
                        //                     fontFamily: "semibold")),
                        //             Text("Est.Delivery time",
                        //                 style: TextStyle(
                        //                     color: Colors.black45,
                        //                     fontSize: 12,
                        //                     fontFamily: "medium")),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        Row(
                          children: [
                            Icon(
                              Icons.share_location,
                              size: 24,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${data['originAddress']}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: "semibold")),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.local_taxi_outlined,
                              size: 24,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${data['destinationAddress']}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: "semibold")),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Chip(
                          backgroundColor: Colors.deepOrange.shade300,
                          label: Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 1, vertical: 1),
                            margin: EdgeInsets.symmetric(vertical: 1),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text("Arrived Date: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontFamily: "semibold")),
                                      Text('${data['time']}',
                                          style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 12,
                                              fontFamily: "medium")),
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
                ),
                // child: Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Container(
                //     margin: EdgeInsets.only(bottom: 2),
                //     child: Row(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Expanded(
                //             child: Container(
                //           padding: EdgeInsets.all(12),
                //           decoration: shadowBox(),
                //           child: Column(
                //             children: [
                //               Row(
                //                 mainAxisAlignment:
                //                     MainAxisAlignment.spaceBetween,
                //                 children: [
                //                   Chip(
                //                     backgroundColor: Colors.lightBlue,
                //                     label: Text('ID : ${data['timestamp']}\$',
                //                         style: nameLabel()),
                //                   ),
                //                   Chip(
                //                     backgroundColor: Colors.white,
                //                     label: RichText(
                //                       text: TextSpan(
                //                         text: 'Price : \$',
                //                         style: TextStyle(
                //                             fontSize: 15,
                //                             color: Colors.lightBlue,
                //                             fontFamily: 'regular'),
                //                         children: <TextSpan>[
                //                           TextSpan(
                //                               text: '${data['totalPayment']}',
                //                               style: TextStyle(
                //                                   fontFamily: 'medium',
                //                                   color: Colors.lightBlue)),
                //                         ],
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //               SizedBox(height: 8),
                //               Row(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Padding(
                //                     padding: EdgeInsets.only(top: 3),
                //                     child: Icon(
                //                       Icons.fiber_manual_record,
                //                       size: 16,
                //                       color: Colors.lightBlue,
                //                     ),
                //                   ),
                //                   SizedBox(width: 12),
                //                   Expanded(
                //                       child: Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: [
                //                       Text('${data['originAddress']}',
                //                           style: boldLabel()),
                //                     ],
                //                   ))
                //                 ],
                //               ),
                //               SizedBox(height: 10),
                //               Row(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Padding(
                //                     padding: EdgeInsets.only(top: 3),
                //                     child: Icon(Icons.fiber_manual_record,
                //                         size: 16, color: Colors.lightBlue),
                //                   ),
                //                   SizedBox(width: 12),
                //                   Expanded(
                //                       child: Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: [
                //                       Text(
                //                           'Price : ${data['destinationAddress']}\$',
                //                           style: boldLabel()),
                //                     ],
                //                   ))
                //                 ],
                //               ),
                //               SizedBox(height: 10),
                //               Chip(
                //                 backgroundColor: Colors.white,
                //                 label: Text('${data['time']}',
                //                     style: TextStyle(color: Colors.lightBlue)),
                //               ),
                //             ],
                //           ),
                //         ))
                //       ],
                //     ),
                //   ),
                // ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
