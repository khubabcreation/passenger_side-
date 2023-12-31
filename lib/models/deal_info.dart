import 'package:cloud_firestore/cloud_firestore.dart';

class DealInfo {
  String? carBrand;
  String? carModel;
  String? carNumber;
  String? commision;
  String? destinationLatitude;
  String? destinationLongitude;
  String? destinationAddress;
  String? distance;
  String? driverId;
  String? driverName;
  String? driverPhone;
  String? driverPhoto;
  String? driverRating;
  String? driverType;
  String? duration;
  String? originLatitude;
  String? originLongitude;
  String? originAddress;
  String? pincode;
  String? status;
  String? time;
  String? timestamp;
  String? totalPayment;
  String? userEmail;
  String? userId;
  String? userName;
  String? userPhone;
  String? userPhoto;

  DealInfo({
    this.carBrand,
    this.carModel,
    this.carNumber,
    this.commision,
    this.destinationLatitude,
    this.destinationLongitude,
    this.destinationAddress,
    this.distance,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverPhoto,
    this.driverRating,
    this.driverType,
    this.duration,
    this.originLatitude,
    this.originLongitude,
    this.originAddress,
    this.pincode,
    this.status,
    this.time,
    this.timestamp,
    this.totalPayment,
    this.userEmail,
    this.userId,
    this.userName,
    this.userPhone,
    this.userPhoto,
  });

  factory DealInfo.fromDocument(DocumentSnapshot doc) {
    return DealInfo(
      carBrand: doc['carBrand'],
      carModel: doc['carModel'],
      carNumber: doc['carModel'],
      commision: doc['commision'],
      destinationLatitude: doc['destinationLatitude'],
      destinationLongitude: doc['destinationLongitude'],
      destinationAddress: doc['destinationAddress'],
      distance: doc['distance'],
      driverId: doc['driverId'],
      driverName: doc['driverName'],
      driverPhone: doc['driverPhone'],
      driverPhoto: doc['driverPhoto'],
      driverRating: doc['driverRating'],
      driverType: doc['driverType'],
      duration: doc['duration'],
      originLatitude: doc['originLatitude'],
      originLongitude: doc['originLongitude'],
      originAddress: doc['originAddress'],
      pincode: doc['pincode'],
      status: doc['status'],
      time: doc['time'],
      timestamp: doc['timestamp'],
      totalPayment: doc['totalPayment'],
      userEmail: doc['userEmail'],
      userId: doc['userId'],
      userName: doc['userName'],
      userPhone: doc['userPhone'],
      userPhoto: doc['userPhoto'],
    );
  }
}
