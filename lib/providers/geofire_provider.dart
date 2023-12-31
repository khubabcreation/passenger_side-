import 'package:flutter3_firestore_passenger/models/nearest_drivers.dart';

class GeoFireProvider {
  static List<nearestDrivers> geoFireDriver = [];
  static List<nearestDrivers> nearestActiveDrivers = [];

  static void deleteOfflineDriverFromList(String driverId) {
    int indexNumber =
        geoFireDriver.indexWhere((element) => element.driverId == driverId);
    geoFireDriver.removeAt(indexNumber);
  }

  static void addActiveNearbyAvailableDriverLocation(
      nearestDrivers driverWhoAdded) {
    int indexNumber = geoFireDriver
        .indexWhere((element) => element.driverId == driverWhoAdded.driverId);

    print("indexNumber");
    print(indexNumber);

    geoFireDriver.removeWhere(
        (deleteDriver) => deleteDriver.driverId == driverWhoAdded.driverId);
    geoFireDriver.add(driverWhoAdded);
  }

  static void updateActiveNearbyAvailableDriverLocation(
      nearestDrivers driverWhoMove) {
    int indexNumber = geoFireDriver
        .indexWhere((element) => element.driverId == driverWhoMove.driverId);

    geoFireDriver[indexNumber].locationLatitude =
        driverWhoMove.locationLatitude;
    geoFireDriver[indexNumber].locationLongitude =
        driverWhoMove.locationLongitude;
  }
}
