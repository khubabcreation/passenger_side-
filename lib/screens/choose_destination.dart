// import 'package:flutter3_firestore_passenger/screens/google_places_ui.dart';
// import 'package:flutter3_firestore_passenger/screens/google_search_by_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_firestore_passenger/screens/google_places_ui.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'dart:async';

import '../models/google_places.dart';
import '../providers/google_map_functions.dart';
import '../providers/http_request_provider.dart';
import 'package:flutter3_firestore_passenger/main_variables/main_variables.dart';
import '../providers/location_provider.dart';
import '../models/directions.dart';

class ChooseDestination extends StatefulWidget {
  ChooseDestination({Key? key}) : super(key: key);

  @override
  State<ChooseDestination> createState() => _ChooseDestinationState();
}

class _ChooseDestinationState extends State<ChooseDestination> {
  List<GooglePlaces> placesPredictedList = [];

  void findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) //2 or more than 2 input characters
    {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$googleMapKey&components=country:MN";

      var responseAutoCompleteSearch =
          await HttpRequestProvider.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch ==
          "Error Occurred, Failed. No Response.") {
        return;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List)
            .map((jsonData) => GooglePlaces.fromJson(jsonData))
            .toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }

  late GoogleMapController googleMapController;

  GeoCode geoCode = GeoCode();
  static const LatLng _center = const LatLng(45.343434, -122.545454);

  LatLng _lastMapPosition = _center;

  late CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 5);

  //late CameraPosition initialCameraPosition;
  Set<Marker> markers = {};

  String _title = "";
  String _detail = "";
  late TextEditingController _lane1;

  late LatLng currentPostion;
  Position? userCurrentPosition;

  double? currentUserLat;
  double? currentUserLong;

  String userName = "your Name";
  String userEmail = "your Email";

  late final Completer<GoogleMapController> _googleMapController = Completer();

  @override
  void initState() {
    super.initState();

    _determinePosition();
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;

    print("onCameraMove");
    print(_lastMapPosition);
    _handleTap(_lastMapPosition);
  }

  _handleTap(LatLng point) {
    markers.clear();
    //_getLocation(point);
    setState(() {
      _lastMapPosition = point;

      markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(title: _title, snippet: _detail),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    });
  }

  // _getLocation(LatLng point) async {

  //   Coordinates coordinates = await geoCode.forwardGeocoding(
  //       address: "532 S Olive St, Los Angeles, CA 90013");
  //   final coordinates = new Coordinates(point.latitude, point.longitude);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var first = addresses.first;
  //   print("${first.featureName} : ${first.addressLine}");

  //   setState(() {
  //     _title = first.featureName;
  //     _detail = first.addressLine;
  //     _lane1.text = _title + "   " + _detail;
  //   });
  // }

  _moveBackScreen() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor:Color(0xFFfd0011),
        elevation: 0,
        title: Text(
          "Choose Destination",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _moveBackScreen();
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              // initialCameraPosition: CameraPosition(
              //   target: currentPostion,
              //   zoom: 10,
              // ),
              markers: markers,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              onCameraMove: _onCameraMove,
              //onTap: _handleTap,
              onMapCreated: (GoogleMapController controller) {
                googleMapController = controller;

                locateUserPosition();
              },
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.only(left: 16, top: 40, right: 16, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              // color: Colors.orangeAccent.withOpacity(0.1),
                              color:Color(0xFFfd0011),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            )
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          // color: Colors.deepOrange.withOpacity(0.7)
                          color:Color(0xFFfd0011),
                      ),
                      child: TextField(
                        onChanged: (valueTyped) {
                          findPlaceAutoCompleteSearch(valueTyped);
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          hintText: 'Please enter your destination',
                          hintStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    )),
                    // SizedBox(width: 16),
                    // FloatingActionButton(
                    //   onPressed: () {
                    //     // Navigator.push(
                    //     //     context,
                    //     //     new MaterialPageRoute(
                    //     //         builder: (context) =>
                    //     //             new GoogleSearchByName()));
                    //   },
                    //   backgroundColor: Colors.lightBlue,
                    //   child: Text(
                    //     'Go',
                    //     style: TextStyle(
                    //         color: Colors.white, fontFamily: 'semi-bold'),
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
          ),
          //display place predictions result
          (placesPredictedList.length > 0)
              ? Expanded(
                  child: ListView.separated(
                    itemCount: placesPredictedList.length,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      // return Container();
                      return GooglePlacesUI(
                        googlePlaces: placesPredictedList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        height: 1,
                        color: Colors.deepOrange,
                        thickness: 1,
                      );
                    },
                  ),
                )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // backgroundColor: Colors.redAccent.withOpacity(0.7),
        backgroundColor:Color(0xFFfd0011),
        onPressed: () async {
          print(_lastMapPosition.latitude);
          print(_lastMapPosition.longitude);

          print("log");

          String apiUrl =
              "https://maps.googleapis.com/maps/api/geocode/json?latlng=${_lastMapPosition.latitude},${_lastMapPosition.longitude}&key=$googleMapKey";
          String humanReadableAddress = "";

          var requestResponse =
              await HttpRequestProvider.receiveRequest(apiUrl);

          print(requestResponse);
          if (requestResponse != "Error Occurred, Failed. No Response.") {
            humanReadableAddress =
                requestResponse["results"][0]["formatted_address"];

            Directions dropOffAddress = Directions();
            dropOffAddress.locationLatitude = _lastMapPosition.latitude;
            dropOffAddress.locationLongitude = _lastMapPosition.longitude;
            dropOffAddress.locationName = humanReadableAddress;
            dropOffAddress.locationId = humanReadableAddress;

            Provider.of<AppInfo>(context, listen: false)
                .updateEndLocation(dropOffAddress);

            setState(() {
              userDropOffAddress = dropOffAddress.locationName!;
            });
          }

          Navigator.pop(context, "obtainedDropoff");

          // Navigator.push(context,MaterialPageRoute(builder: (context) => AddNewAddress(latitude: _lastMapPosition.latitude,longitude: _lastMapPosition.longitude)));
        },
        label: const Text("Choose Destination"),
        icon: const Icon(Icons.edit_road),
      ),
    );
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    setState(() {
      currentUserLat = userCurrentPosition!.latitude;
      currentUserLong = userCurrentPosition!.longitude;
    });

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await GoogleMapFunctions.searchAddressForGeographicCoOrdinates(
            userCurrentPosition!, context);
    print("this is your addresss = " + humanReadableAddress);

    setState(() {
      userStartAddress = humanReadableAddress;
    });

    userName = userModelCurrentInfo!.displayName!;
    print(userName);
    userEmail = userModelCurrentInfo!.email!;
    print(userEmail);

    // initializeGeoFireListener();

    // GoogleMapFunctions.readTripsKeysForOnlineUser(context);
  }

  Future<LatLng> getCenter() async {
    final GoogleMapController controller = await _googleMapController.future;
    LatLngBounds visibleRegion = await controller.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );

    return centerLatLng;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
    });

    final CameraPosition initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 14);

    return position;
  }
}
