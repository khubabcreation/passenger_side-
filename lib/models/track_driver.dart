import 'package:cloud_firestore/cloud_firestore.dart';

class TrackDriver {
  String? latitude;
  String? longitude;

  TrackDriver({
    this.latitude,
    this.longitude,
  });

  factory TrackDriver.fromDocument(DocumentSnapshot doc) {
    return TrackDriver(
      latitude: doc['latitude'],
      longitude: doc['longitude'],
    );
  }
}
