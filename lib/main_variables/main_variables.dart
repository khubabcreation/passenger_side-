import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter3_firestore_passenger/models/direction_details_info.dart';
import 'package:geolocator/geolocator.dart';

import '../models/users.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
Users? userModelCurrentInfo;
List dList = []; //online-active drivers Information List
DirectionDetailsInfo? tripDirectionDetailsInfo;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
String? chosenDriverId = "";
String cloudMessagingServerToken =
    "key=AAAADzQSdxM:APA91bGu7kQT0PLr_ID8OZHDN2dbb4RbThouU88zOVINbVzCj_8DyHEzOpBQp8AJRXOl9naReH-MQQFSzrtSQzmzcRRRKq0wABZyw99QPwddXHHskK2aiWZuJigG2B1CbEa958zuaTL_";
String userDropOffAddress = "";
String userStartAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";
// String googleMapKey = "Your Google Map Api Key";
String googleMapKey = "AIzaSyALNzzYtLGfBMif_EM8_a6ssJjYnuB1NQA";
String rands = "R";
// String googleMapKey = "AIzaSyB0ozOOKPbqFFpWPKqBuLveqPqsXYee_ME";
