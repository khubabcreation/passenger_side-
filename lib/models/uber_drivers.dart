import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class uberDrivers {
  String? driverId;
  String? driverName;
  String? driverEmail;
  String? carBrand;
  String? carModel;
  String? carNumber;
  String? carType;
  Map? position;
  String? priceKm;
  String? priceMin;
  String? driverPhone;
  String? driverPhoto;

  uberDrivers(
      {this.driverId,
      this.driverName,
      this.driverEmail,
      this.carBrand,
      this.carModel,
      this.carNumber,
      this.carType,
      this.position,
      this.priceKm,
      this.priceMin,
      this.driverPhoto,
      this.driverPhone});

  factory uberDrivers.fromDocument(DocumentSnapshot doc) {
    return uberDrivers(
      driverId: doc['driverId'],
      driverName: doc['driverName'],
      driverEmail: doc['driverEmail'],
      carBrand: doc['carBrand'],
      carModel: doc['carModel'],
      carNumber: doc['carNumber'],
      carType: doc['carType'],
      priceKm: doc['priceKm'],
      priceMin: doc['priceMin'],
      position: doc['position'],
      driverPhoto: doc['driverPhoto'],
      driverPhone: doc['phone'],
    );
  }
}
