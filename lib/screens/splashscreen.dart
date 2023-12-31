import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter3_firestore_passenger/providers/google_map_functions.dart';

import 'package:flutter3_firestore_passenger/main_variables/main_variables.dart';
import 'package:flutter3_firestore_passenger/screens/tabs.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splashscreen extends StatefulWidget {
  Splashscreen({Key? key}) : super(key: key);

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  startTimer() {
    fAuth.currentUser != null
        ? GoogleMapFunctions.readCurrentOnlineUserInfo()
        : null;

    Timer(const Duration(seconds: 4), () async {
      currentFirebaseUser = fAuth.currentUser;
      Navigator.push(context, MaterialPageRoute(builder: (c) => TabsScreen()));
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        // color: Colors.redAccent.shade100,
        color: Color(0xFFfd0011),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('images/splash.json'),
              Text(
                "Arryvd Customer Application",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              // Image.asset("images/logo.png"),
              // const SizedBox(
              //   height: 10,
              // ),
              // const Text(
              //   "Uber & inDriver Clone App",
              //   style: TextStyle(
              //       fontSize: 24,
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
