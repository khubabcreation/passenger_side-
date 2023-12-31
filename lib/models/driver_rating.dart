import 'package:cloud_firestore/cloud_firestore.dart';

class DriverRating {
  String? ratings;

  DriverRating({
    this.ratings,
  });

  factory DriverRating.fromDocument(DocumentSnapshot doc) {
    return DriverRating(
      ratings: doc['ratings'],
    );
  }
}
