import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_firestore_passenger/screens/login_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter3_firestore_passenger/screens/tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'sign_screen.dart';

class RegisterUI extends StatefulWidget {
  RegisterUI({Key? key}) : super(key: key);

  @override
  State<RegisterUI> createState() => _RegisterUIState();
}

class _RegisterUIState extends State<RegisterUI> {
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
  File? imageFile;
  updateState(){
    if(mounted){
      setState(() {

      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              key: _scaffoldKey,
              // backgroundColor: Colors.deepOrange.shade300,
              backgroundColor: Color(0xFFf6efef),
              body: SingleChildScrollView(
                reverse: true,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'bold',
                                  // color: Colors.white,
                                    color: const Color(0xFFfd0011)                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Create a new account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'medium',
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              // Center(
                              //     child: SizedBox(
                              //       height: 115,
                              //       width: 115,
                              //       child: Stack(
                              //         fit: StackFit.expand,
                              //         clipBehavior: Clip.none,
                              //         children: [
                              //           imageFile == null ? CircleAvatar(
                              //             backgroundImage: AssetImage("assets/ali.png"),
                              //           ) : CircleAvatar(
                              //             backgroundImage: FileImage(imageFile!),
                              //           ),
                              //           Positioned(
                              //             right: -16,
                              //             bottom: 0,
                              //             child: SizedBox(
                              //               height: 46,
                              //               width: 46,
                              //               child: TextButton(
                              //                 style: TextButton.styleFrom(
                              //                   shape: RoundedRectangleBorder(
                              //                     borderRadius: BorderRadius.circular(50),
                              //                     side: BorderSide(color: Colors.green),
                              //                   ),
                              //                   primary: Colors.white,
                              //                   backgroundColor: Color(0xFFF5F6F9),
                              //                 ),
                              //                 onPressed: () async {
                              //                   final ImagePicker _picker = ImagePicker();
                              //                   // Pick an image
                              //                   XFile? image = await _picker.pickImage(
                              //                       source: ImageSource.gallery);
                              //                   imageFile = File(image!.path);
                              //                   updateState();
                              //                 },
                              //                 child: Image.asset(
                              //                     "assets/icons/Camera Icon.svg"),
                              //               ),
                              //             ),
                              //           )
                              //         ],
                              //       ),
                              //     )
                              //
                              //
                              // ),
                                  SizedBox(
                                height: 10,
                              ),




                              TextFormField(
                                controller: displayName,
                                decoration: InputDecoration(
                                  hintText: 'Firstname',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: InputBorder.none,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: lastName,
                                decoration: InputDecoration(
                                  hintText: 'Lastname',
                                  prefixIcon: Icon(Icons.person_rounded),
                                  border: InputBorder.none,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: address,
                                decoration: InputDecoration(
                                  hintText: 'Address',
                                  prefixIcon: Icon(Icons.home),
                                  border: InputBorder.none,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: phone,
                                decoration: InputDecoration(
                                  hintText: 'Phonenumber',
                                  prefixIcon: Icon(Icons.phone),
                                  border: InputBorder.none,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: email,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: InputBorder.none,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                obscureText: true,
                                controller: password,
                                decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                    border: InputBorder.none),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(fontFamily: 'semi-bold'),
                                ),
                                onPressed: () async {
                                  FirebaseAuth.instance
                                      .authStateChanges()
                                      .listen((User? user) async {
                                    if (user == null) {
                                      try {
                                        UserCredential userCredential =
                                            await FirebaseAuth.instance
                                                .createUserWithEmailAndPassword(
                                                    email: email.text,
                                                    password: password.text);
                                      } on FirebaseAuthException catch (e) {
                                        if (displayName.text.isEmpty) {
                                          Fluttertoast.showToast(
                                            msg: 'enter valid first_name',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Color(0xFFfd0011),
                                            textColor: Colors.white,
                                          );
                                        } else if (lastName.text.isEmpty) {
                                          Fluttertoast.showToast(
                                            msg: 'enter valid last_name',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor:Color(0xFFfd0011),
                                            textColor: Colors.white,
                                          );
                                        }
                                        else if (address.text.isEmpty) {
                                          Fluttertoast.showToast(
                                            msg: 'enter valid address',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Color(0xFFfd0011),
                                            textColor: Colors.white,
                                          );
                                        }

                                        else if (phone.text.isEmpty) {
                                          Fluttertoast.showToast(
                                            msg: 'enter valid phone number',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Color(0xFFfd0011),
                                            textColor: Colors.white,
                                          );
                                        }
                                        else if (!EmailValidator.validate(
                                            email.text)) {
                                          Fluttertoast.showToast(
                                            msg: 'enter valid email',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Color(0xFFfd0011),
                                            textColor: Colors.white,
                                          );
                                        }else if (password.text.isEmpty) {
                                          Fluttertoast.showToast(
                                            msg: 'enter valid password',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Color(0xFFfd0011),
                                            textColor: Colors.white,
                                          );
                                        }


                                        else  if (e.code == 'weak-password') {
                                          Fluttertoast.showToast(
                                            msg: 'The password provided is too weak',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Color(0xFFfd0011),
                                            textColor: Colors.white,
                                          );
                                          print(
                                              'The password provided is too weak.');
                                        } else if (e.code ==
                                            'email-already-in-use') {
                                          Fluttertoast.showToast(
                                            msg: 'The account already exists for that email.',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 2,
                                            backgroundColor: Color(0xFFfd0011),
                                            textColor: Colors.white,
                                          );
                                          print(
                                              'The account already exists for that email.');
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    } else {
                                      var currentUser =
                                          FirebaseAuth.instance.currentUser;

                                      CollectionReference? users =
                                          FirebaseFirestore.instance
                                              .collection('users');

                                      return users.doc(currentUser?.uid).set({
                                        "id": currentUser!.uid,
                                        "displayName": displayName.text,
                                        "name": displayName.text,
                                        "lastName": lastName.text,
                                        "address": address.text,
                                        "phone": phone.text,
                                        "email": email.text,
                                        "photoURL":
                                        // imageFile!.absolute.path
                                        "https://firebasestorage.googleapis.com/v0/b/arryv-d.appspot.com/o/1668676238538man.png?alt=media&token=10c30776-abd9-4a8d-882f-5b76ff05e4a3"

                                        // "https://firebasestorage.googleapis.com/v0/b/arryv-d.appspot.com/o/users%2FNb1wBH4QIDQ5hlRld2T7HvXJvSU2?alt=media&token=68a85266-0423-40be-854e-3c87d2d30bc3",
                                        // "https://firebasestorage.googleapis.com/v0/b/my-uber-taxi.appspot.com/o/users%2FNb1wBH4QIDQ5hlRld2T7HvXJvSU2?alt=media&token=68a85266-0423-40be-854e-3c87d2d30bc3",
                                      }).then((value) {
                                        print("User Added");
                                      }).catchError((error) =>
                                          print("Failed to add user: $error"));
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  // primary: Colors.deepOrange,
                                  primary: Color(0xFFfd0011) ,
                                  onPrimary: Colors.white,
                                  minimumSize: const Size.fromHeight(60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                // color: Colors.deepOrange.shade100,
                color: Color(0xFFf6efef),
                padding: EdgeInsets.all(16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginUI()));
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Already have an account?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'regular'),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                                fontFamily: 'semi-bold',
                                // color: Colors.deepOrange
                                color: Color(0xFFfd0011),
                            )),
                      ],
                    ),
                  ),
                ),
              ), //textform
            );
          }

          return TabsScreen();
        });
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      reverse: true,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'bold',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Create a new account',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'medium',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Firstname',
                      prefixIcon: Icon(Icons.person_outline),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Lastname',
                      prefixIcon: Icon(Icons.person_rounded),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Address',
                      prefixIcon: Icon(Icons.home),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Phonenumber',
                      prefixIcon: Icon(Icons.phone),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: InputBorder.none),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: const Text(
                      "Sign up",
                      style: TextStyle(fontFamily: 'semi-bold'),
                    ),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrange,
                      onPrimary: Colors.white,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
