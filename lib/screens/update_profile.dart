import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'tabs.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/users.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateDriver extends StatefulWidget {
  UpdateDriver({Key? key}) : super(key: key);

  @override
  State<UpdateDriver> createState() => _UpdateDriverState();
}

class _UpdateDriverState extends State<UpdateDriver> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String photoURL = '';
  String error = '';

  final email = TextEditingController();

  final password = TextEditingController();

  final address = TextEditingController();

  final displayName = TextEditingController();

  final lastName = TextEditingController();

  final phone = TextEditingController();

  String? _userId;

  Users? user;
  String? imageUrl;
  Future selectImage(ImageSource source) async {
    try {
      ImagePicker imagePicker = ImagePicker();
      XFile? imagefile = await imagePicker.pickImage(source: source,   imageQuality: 80);
      File imageFile = File(imagefile!.path);
      if(imageFile == null ) return 'there is no image';
      print(imageFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final storageRef = FirebaseStorage.instance.ref().child("images/");

      await storageRef.putFile(imageFile);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  uploadImage(uid) async {
    //final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile? image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image

      image = (await _imagePicker.getImage(source: ImageSource.gallery))!;
      var file = File(image.path);



      try {
        firebase_storage.UploadTask task = firebase_storage
            .FirebaseStorage.instance
            .ref('users/${uid}')
            .putFile(file);

        task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
          print('Task state: ${snapshot.state}');
          print(
              'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
        }, onError: (e) {
          // The final snapshot is also available on the task via `.snapshot`,
          // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
          print(task.snapshot);

          if (e.code == 'permission-denied') {
            print('User does not have permission to upload to this reference.');
          }
        });

        try {
          await task;
          String downloadURL = await firebase_storage.FirebaseStorage.instance
              .ref('users/${uid}')
              .getDownloadURL();

          var currentUser = FirebaseAuth.instance.currentUser;

          // DatabaseReference ref = FirebaseDatabase.instance.ref("users");

          // ref.child(currentUser!.uid).update({
          //   "photoURL": downloadURL,
          // }).then((value) {
          //   Navigator.push(
          //       context, MaterialPageRoute(builder: (context) => TabsScreen()));
          //   print("User Added");
          // }).catchError((error) => print("Failed to add user: $error"));

          CollectionReference? users =
              FirebaseFirestore.instance.collection('users');

          users.doc(currentUser!.uid).update({
            "photoURL": downloadURL,
          }).then((value) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => TabsScreen()));
          }).catchError((error) => print("Failed to add user: $error"));

          // CollectionReference? users =
          //     FirebaseFirestore.instance.collection('users');

          // var currentUser = FirebaseAuth.instance.currentUser;

          // print(displayName.text);
          // users.doc(uid).update({
          //   "photoURL": downloadURL,
          // }).then((value) {
          //   Navigator.push(
          //       context, MaterialPageRoute(builder: (context) => TabsScreen()));
          //   print("User Added");
          // }).catchError((error) => print("Failed to add user: $error"));
        } on firebase_core.FirebaseException catch (e) {
          // e.g, e.code == 'canceled'
        }
        print('Upload complete.');
      } on firebase_core.FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          print('User does not have permission to upload to this reference.');
        }
        // ...
      }

      //Upload to Firebase
      // var snapshot = await _firebaseStorage
      //     .ref()
      //     .child('images/imageName')
      //     .putFile(file)
      //     .then((p0) {
      //   print("uploaded successfully");
      // }).onError((error, stackTrace) {
      //   print(error);
      // });
      // var downloadUrl = await snapshot.ref.getDownloadURL();
      // setState(() {
      //   imageUrl = downloadUrl;
      // });
    }
    else {
      print('Permission not granted. Try Again with permission access');
    }
  }

  @override
  void initState() {
    //getRestaurants();
    super.initState();

    var currentUser_uid = FirebaseAuth.instance.currentUser!.uid;

    // final ref = FirebaseDatabase.instance.ref();

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser_uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          user = Users.fromDocument(documentSnapshot);

          print("driver_details");
          print(user);

          displayName.text = user!.displayName!;
          lastName.text = user!.lastName!;
          email.text = user!.email!;
          phone.text = user!.phone!;
          address.text = user!.address!;
        });

        // print("driverInfoCounting");
        // print(driverInfo);

        print("newAverageRatings");
        print(user!.displayName);
      }
    });
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("users")
    //     .child(currentUser_uid)
    //     .once()
    //     .then((snap) {
    //   if (snap.snapshot.value != null) {
    //     setState(() {
    //       user = Users.fromSnapshot(snap.snapshot);

    //       print("driver_details");
    //       print(user);

    //       displayName.text = user!.displayName!;
    //       lastName.text = user!.lastName!;
    //       email.text = user!.email!;
    //       phone.text = user!.phone!;
    //       address.text = user!.address!;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      appBar: AppBar(
        // backgroundColor: Colors.redAccent.shade100,
        backgroundColor:Color(0xFFfd0011),
        elevation: 0.0,
        title: Text('Update Profile'),
        automaticallyImplyLeading: true,
        /**
				actions: <Widget>[
					FlatButton.icon(
						icon: Icon(Icons.person),
						label: Text(''),
						onPressed: () {
							widget.toggleView();
						},
					),
				],//action
				**/
      ), //appBar
      body: Container(
        color: Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              // CollectionReference? users = FirebaseFirestore
                              //     .instance
                              //     .collection('users');

                              var currentUser =
                                  FirebaseAuth.instance.currentUser;

                              //uploadExample();
                              await uploadImage(currentUser?.uid);
                              // print(displayName.text);
                              // users.doc(currentUser?.uid).update({
                              //   "id": currentUser?.uid,
                              //   "displayName": displayName.text,
                              //   "lastName": lastName.text,
                              //   "address": address.text,
                              //   "phone": phone.text,
                              //   "email": email.text,
                              // }).then((value) {
                              //   Navigator.push(context,
                              //       MaterialPageRoute(builder: (context) => TabsScreen()));
                              //   print("User Added");
                              // }).catchError((error) => print("Failed to add user: $error"));
                            },
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage('${user?.photoURL}'
                                            //'assets/payment.png',
                                            //'${user?.photoURL}',
                                            ),
                                    radius: 40,

                                    // Image.network(
                                    //   ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: displayName,
                    decoration: InputDecoration(
                        hintText: 'Firstname', labelText: 'Firstname'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: lastName,
                    decoration: InputDecoration(
                        hintText: 'Lastname', labelText: 'Lastname'),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: address,
                    decoration: InputDecoration(
                        hintText: 'Address', labelText: 'Address'),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: phone,
                    decoration: InputDecoration(
                      
                        hintText: 'Phonenumber', labelText: 'Phonenumber'),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, top: 7.0, right: 28.0, bottom: 7.0),
                  child: TextFormField(
                    controller: email,
                    enabled: false,
                    decoration:
                        InputDecoration(hintText: 'Email', labelText: 'Email'),
                  ),
                ),

                Text(
                  error,
                  style: TextStyle(color: Colors.lightBlue, fontSize: 7.0),
                ), //text

                Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            var currentUser = FirebaseAuth.instance.currentUser;

                            CollectionReference? users =
                                FirebaseFirestore.instance.collection('users');

                            users.doc(currentUser!.uid).update({
                              "id": currentUser.uid,
                              "displayName": displayName.text,
                              "name": displayName.text,
                              "lastName": lastName.text,
                              "address": address.text,
                              "phone": phone.text,
                              "email": email.text,
                            }).then((value) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TabsScreen()));
                            }).catchError(
                                (error) => print("Failed to add user: $error"));
                          },
                          child: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                            elevation: 0,
                            // primary: Colors.deepOrange,
                            primary: Color(0xFFfd0011),
                            onPrimary: Colors.white,
                            textStyle: TextStyle(
                                fontFamily: 'medium',
                                fontSize: 16,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ),
                    // ButtonTheme(
                    //   minWidth: 320.0,
                    //   height: 45.0,
                    //   child: OutlinedButton(
                    //     // shape: RoundedRectangleBorder(
                    //     //     borderRadius: BorderRadius.circular(7.0)),
                    //     // color: Colors.deepOrange,
                    //     onPressed: () async {
                    //       var currentUser = FirebaseAuth.instance.currentUser;

                    //       CollectionReference? users =
                    //           FirebaseFirestore.instance.collection('users');

                    //       users.doc(currentUser!.uid).update({
                    //         "id": currentUser.uid,
                    //         "displayName": displayName.text,
                    //         "name": displayName.text,
                    //         "lastName": lastName.text,
                    //         "address": address.text,
                    //         "phone": phone.text,
                    //         "email": email.text,
                    //       }).then((value) {
                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) => TabsScreen()));
                    //       }).catchError(
                    //           (error) => print("Failed to add user: $error"));
                    //     },
                    //     child: Text('Save',
                    //         style:
                    //             TextStyle(color: Colors.white, fontSize: 20)),
                    //   ), //rec
                    // ), //flat
                  ], //widget
                ), //column
              ],
            ),
          ),
        ),
      ), //textform
    );

    // return TabsScreen();
  }
}
