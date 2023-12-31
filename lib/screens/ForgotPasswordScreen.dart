import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';



class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final emailController =TextEditingController();
  final auth = FirebaseAuth.instance ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Color(0xFFfd0011),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
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

                hintText: 'enter a email',
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

            SizedBox(height: 40,),
            Container(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (!EmailValidator.validate(emailController.text)) {
                    Fluttertoast.showToast(
                      msg: 'enter valid email',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor:  Color(0xFFfd0011),
                      textColor: Colors.white,
                    );
                  }
                  auth.sendPasswordResetEmail(email: emailController.text.toString()).then((value){
                    Utils().toastMessage('We have sent you email to recover password, please check email');
                  }).onError((error, stackTrace){
                    // Utils().toastMessage(error.toString());
                  });
                },
                child: Text('Forgot password'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
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
      /*      // MaterialButton(
            //     color: const Color(0xFFfd0011),
            //     onPressed: (){
            //   auth.sendPasswordResetEmail(email: emailController.text.toString()).then((value){
            //     Utils().toastMessage('We have sent you email to recover password, please check email');
            //   }).onError((error, stackTrace){
            //     Utils().toastMessage(error.toString());
            //   });
            //
            // },
            //     child: Text("Forgot password")
            //
            // )
            // // RoundButton(title: 'Forgot'
            // //
            // //     , onTap: (){
            // //   auth.sendPasswordResetEmail(email: emailController.text.toString()).then((value){
            // //     Utils().toastMessage('We have sent you email to recover password, please check email');
            // //   }).onError((error, stackTrace){
            // //     Utils().toastMessage(error.toString());
            // //   });
            // // })*/
          ],
        ),
      ),
    );
  }
}

class Utils {


  void toastMessage(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0
    );
  }
}