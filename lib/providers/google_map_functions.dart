import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter3_firestore_passenger/providers/http_request_provider.dart';
import 'package:flutter3_firestore_passenger/main_variables/main_variables.dart';
import 'package:flutter3_firestore_passenger/providers/location_provider.dart';
import 'package:flutter3_firestore_passenger/models/direction_details_info.dart';
import 'package:flutter3_firestore_passenger/models/directions.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/users.dart';

class GoogleMapFunctions {
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
    String humanReadableAddress = "";

    var requestResponse = await HttpRequestProvider.receiveRequest(apiUrl);
    print(requestResponse);

    if (requestResponse != "Error Occurred, Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updateStartLocation(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentFirebaseUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        //String deviceRegistrationToken = documentSnapshot.data()["token"];

        userModelCurrentInfo = Users.fromDocument(documentSnapshot);

        print("arryvdUser");
        print(userModelCurrentInfo);

        // print("chosenDriverId");
        // print(chosenDriverId);

        // //send Notification Now
        // GoogleMapFunctions.sendNotificationToDriverNow(
        //   uberDriver.token!,
        //   chosenDriverId,
        //   context,
        // );

        //Fluttertoast.showToast(msg: "Notification sent Successfully.");
      } else {
        print('Document does not exist on the database');
      }
    });

    // DatabaseReference userRef = FirebaseDatabase.instance
    //     .ref()
    //     .child("users")
    //     .child(currentFirebaseUser!.uid);

    // userRef.once().then((snap) {
    //   if (snap.snapshot.value != null) {
    //     userModelCurrentInfo = Users.fromSnapshot(snap.snapshot);
    //   }
    // });
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng origionPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$googleMapKey";

    var responseDirectionApi = await HttpRequestProvider.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "Error Occurred, Failed. No Response.") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo, price, timePrice) {
    // double timeTraveledFareAmountPerMinute =
    //     (directionDetailsInfo.duration_value! / 60) * 0.5;
    // double distanceTraveledFareAmountPerKilometer =
    //     (directionDetailsInfo.duration_value! / 1000) * 5;

    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.distance_value! / 60) * timePrice;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.duration_value! / 1000) * price;

    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static sendNotificationToDriverNow(
      String deviceRegistrationToken, String userRideRequestId, context) async {
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification = {
      "body":
          "Start Address: \n$userStartAddress \nDestination Address: \n$destinationAddress.",
      "title": "New Uber Request"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }
}
