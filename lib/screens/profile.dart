import 'package:flutter3_firestore_passenger/screens/login_ui.dart';
import 'package:flutter3_firestore_passenger/screens/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/users.dart';

import 'package:flutter/material.dart';



import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _userId;

  Users? user;

  @override
  void initState() {
    //getRestaurants();
    super.initState();

    var currentUser_uid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser_uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          user = Users.fromDocument(documentSnapshot);
        });

        // print("driverInfoCounting");
        // print(driverInfo);

        print("newAverageRatings");
        print(user!.displayName);
      }
    });

    // final ref = FirebaseDatabase.instance.ref();
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("users")
    //     .child(currentUser_uid)
    //     .once()
    //     .then((snap) {
    //   if (snap.snapshot.value != null) {
    //     setState(() {
    //       // user = Users.fromSnapshot(snap.snapshot);

    //       // print("driver_details");
    //       // print(user);
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      elevation: 0,

      backgroundColor:Color(0xFFfd0011),
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'Account',
        style: TextStyle(
          fontFamily: 'medium',
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('${user?.photoURL}'
                      //'assets/payment.png',
                      //'${user?.photoURL}',
                      ),
                  radius: 40,

                  // Image.network(
                  //   ),
                ),
                Text(
                  '${user?.displayName.toString()}' ' ${user?.lastName.toString()}',
                  // '${user?.displayName.toString()}' ' ${user?.lastName.toString()}',
                  style: TextStyle(
                      fontFamily: 'medium',
                      fontSize: 25,
                     color: Colors.black
                    // color: Colors.deepOrange
                  ),
                ),
                Text('${user?.email}',
                    style: TextStyle(fontSize: 15,
                        // color: Colors.deepOrange
                        color: Colors.black

                    )),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 20.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Account',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'regular',
                        // color: Colors.deepOrange
                        color: Colors.black

                    ),

                  ),
                  SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateDriver()));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          // color: Colors.deepOrange,
                            color: Colors.black

                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('Edit Profile',
                                style: TextStyle(
                                // color: Colors.deepOrange
                                    color: Colors.black

                                )),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          // color: Colors.deepOrange,
                            color: Colors.black

                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      FirebaseAuth.instance.signOut();

                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginUI()));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_outlined,
                          // color: Colors.deepOrange,
                            color: Colors.black

                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('Log Out',
                                style: TextStyle(
                                    // color: Colors.deepOrange
                                    color: Colors.black

                                )),

                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
