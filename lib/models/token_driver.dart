import 'package:cloud_firestore/cloud_firestore.dart';

class TokenDriver {
  String? token;

  TokenDriver({
    this.token,
  });

  factory TokenDriver.fromDocument(DocumentSnapshot doc) {
    return TokenDriver(
      token: doc['token'],
    );
  }
}
