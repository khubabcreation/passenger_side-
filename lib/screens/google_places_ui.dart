import 'package:flutter/material.dart';

import '../main_variables/main_variables.dart';
import '../models/directions.dart';
import '../models/google_places.dart';
import '../progress/progress_dialog.dart';
import '../providers/http_request_provider.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class GooglePlacesUI extends StatefulWidget {
  final GooglePlaces? googlePlaces;

  GooglePlacesUI({this.googlePlaces});

  @override
  State<GooglePlacesUI> createState() => _GooglePlacesUIState();
}

class _GooglePlacesUIState extends State<GooglePlacesUI> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapKey";

    var responseApi =
        await HttpRequestProvider.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if (responseApi == "Error Occurred, Failed. No Response.") {
      return;
    }


    if (responseApi["status"] == "OK") {
      Directions directions = Directions();

      print("responseApi");
      print(responseApi["result"]["name"]);
      print(responseApi["result"]);
      directions.locationName = responseApi["result"]["formatted_address"];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false)
          .updateEndLocation(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.googlePlaces!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.white.withOpacity(0.9),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    widget.googlePlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    widget.googlePlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 14.0,
            ),
            const Icon(
              Icons.share_location,
              color: Colors.deepOrange,
            ),
          ],
        ),
      ),
    );
  }
}
