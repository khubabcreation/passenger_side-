import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter3_firestore_passenger/screens/login_ui.dart';
import 'package:flutter3_firestore_passenger/screens/register.dart';
import 'package:flutter3_firestore_passenger/screens/register_ui.dart';
import 'package:flutter3_firestore_passenger/screens/splashscreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ForgotPasswordScreen.dart';

class LoginUI extends StatefulWidget {
  LoginUI({Key? key}) : super(key: key);

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  String email = '';
  String password = '';
  String error = '';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.grey.shade200,
              body: SingleChildScrollView(
                child: Container(
                  // color: Colors.deepOrange.shade300,
                 // color: Colors.deepOrange.shade100,
                  color: const Color(0xFFf6efef),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Image.asset(

                          'assets/arryvd.png',
                          height: 250,
                          width: 250,
                        ),
                      ),
                      // Container(
                      //   //alignment: Alignment.center, // use aligment

                      //   child: Image.asset('images/Elegant.png',
                      //       height: 200, width: 200, fit: BoxFit.cover),
                      // ),
                      // Text(
                      //   'UBER TAXI APPLICATION',
                      //   style: TextStyle(
                      //       fontSize: 25,
                      //       color: Colors.white,
                      //       fontFamily: "medium",
                      //       fontWeight: FontWeight.w800,
                      //       letterSpacing: 0.1),
                      // ),
                      SizedBox(height: 20),


                      TextFormField(
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "* Required";
                          } else
                            return null;
                        },
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey, width: 2.0),
                              borderRadius:  BorderRadius.circular(50.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey, width: 2.0),
                              borderRadius:  BorderRadius.circular(50.0),
                            ),

                            hintText: 'customer@gmail.com',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            // fillColor: Colors.deepOrange.shade100,
                            // fillColor: Color(0xFFf5eded),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),


                            // focusedBorder: outlineBorder(),
                            // enabledBorder: outlineBorder()
                        ),

                      ),
                      SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        onChanged: (val) {
                          setState(() => password = val);
                        }, //
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey, width: 2.0),
                            borderRadius:  BorderRadius.circular(50.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey, width: 2.0),
                            borderRadius:  BorderRadius.circular(50.0),
                          ),
                            hintText: '123456789',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            // fillColor: Colors.deepOrange.shade100,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            border: outlineBorder(),
                            // focusedBorder: outlineBorder(),
                            // enabledBorder: outlineBorder()
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => new ForgotPasswordScreen()));
                          },
                          child: Container(child:
                          Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: const Color(0xFFfd0011)
                                // color: Colors.white
                            ),
                          ),),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                            } on FirebaseAuthException catch (e) {


                              if (!EmailValidator.validate(email)) {
                                Fluttertoast.showToast(
                                  msg: 'enter valid email',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor:  Color(0xFFfd0011),
                                  textColor: Colors.white,
                                );
                              }
                              else if (password.isEmpty) {
                                Fluttertoast.showToast(
                                  msg: 'enter valid password',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Color(0xFFfd0011),
                                  textColor: Colors.white,
                                );
                              }
                              // if(email.isEmpty == 'Enter a email') {
                              //   Fluttertoast.showToast(
                              //     msg: 'Enter a email.',
                              //     toastLength: Toast.LENGTH_SHORT,
                              //     gravity: ToastGravity.CENTER,
                              //     timeInSecForIosWeb: 2,
                              //     backgroundColor: Color(0xFFfd0011),
                              //     textColor: Colors.white,
                              //   );
                              //   print('Enter a email');
                              // }



                              else if  (e.code == 'user-not-found') {
                                Fluttertoast.showToast(
                                  msg: 'No user found for that email.',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Color(0xFFfd0011),
                                  textColor: Colors.white,
                                );
                                print('No user found for that email.');
                              } else if (e.code == 'wrong-password') {
                                Fluttertoast.showToast(
                                  msg: 'Wrong password provided for that user.',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Color(0xFFfd0011),
                                  textColor: Colors.white,
                                );
                                print('Wrong password provided for that user.');
                              }
                            }
                            // Navigator.push(
                            //     context,
                            //     new MaterialPageRoute(
                            //         builder: (context) => new TabsExample()));
                          },
                          child: Text('Sign In'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
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
                      SizedBox(height: 150),
                      // Container(
                      //   width: double.infinity,
                      //   child: ElevatedButton(
                      //     onPressed: () {},
                      //     child: Text('Sign In with Facebook'),
                      //     style: facebookButton(),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: _buildBottomContainer(),
            );
            //end
          }

          return Splashscreen();
        });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     // appBar: AppBar(
  //     //   backgroundColor: Colors.deepOrange.shade300,
  //     //   iconTheme: IconThemeData(color: Colors.black, size: 30),
  //     //   automaticallyImplyLeading: false,
  //     //   elevation: 0,
  //     // ),
  //     body: _buildBody(context),
  //     bottomNavigationBar: _buildBottomContainer(),
  //   );
  // }

  Widget _buildBody(context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.deepOrange.shade300,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset(
              'images/Elegant.png',
              height: 250,
              width: 250,
            ),
            // Container(
            //   //alignment: Alignment.center, // use aligment

            //   child: Image.asset('images/Elegant.png',
            //       height: 200, width: 200, fit: BoxFit.cover),
            // ),
            Text(
              'UBER TAXI APPLICATION',
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontFamily: "medium",
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.deepOrange.shade100,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: outlineBorder(),
                  focusedBorder: outlineBorder(),
                  enabledBorder: outlineBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.deepOrange.shade100,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: outlineBorder(),
                  focusedBorder: outlineBorder(),
                  enabledBorder: outlineBorder()),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     new MaterialPageRoute(
                  //         builder: (context) => new ForgotPage()));
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     new MaterialPageRoute(
                  //         builder: (context) => new TabsExample()));
                },
                child: Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  primary: Colors.deepOrange,
                  onPrimary: Colors.white,
                  textStyle: TextStyle(
                      fontFamily: 'medium', fontSize: 16, letterSpacing: 0.5),
                ),
              ),
            ),
            SizedBox(height: 150),
            // Container(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () {},
            //     child: Text('Sign In with Facebook'),
            //     style: facebookButton(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  facebookButton() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      primary: Color.fromARGB(255, 0, 148, 254),
      onPrimary: Colors.white,
      textStyle:
          TextStyle(fontFamily: 'medium', fontSize: 16, letterSpacing: 0.5),
    );
  }

  Widget _buildBottomContainer() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RegisterUI()));
      },
      child: Container(
        padding: EdgeInsets.all(16),
        // color: Colors.deepOrange.shade100,
        color: const Color(0xFFf6efef),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'You don\'t have an account? ',
            style: TextStyle(
                fontSize: 16, color: Colors.black, fontFamily: 'regular'),
            children: <TextSpan>[
              TextSpan(
                  text: 'Sign up', style: TextStyle(
                  // color: Colors.deepOrange
                  color: Color(0xFFfd0011),
              )),
            ],
          ),
        ),
      ),
    );
  }

  outlineBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide:
            BorderSide(width: 1, color: Color.fromARGB(255, 238, 241, 247)));
  }
}
