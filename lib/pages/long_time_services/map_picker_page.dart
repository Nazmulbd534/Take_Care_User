import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart' as gc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/map_styles.dart';

import '../../public_variables/variables.dart';

class CustomMapPicker extends StatefulWidget {
  final Location? location;
  const CustomMapPicker({super.key, this.location});

  @override
  State<CustomMapPicker> createState() => _CustomMapPickerState();
}

class _CustomMapPickerState extends State<CustomMapPicker> {
  static final CameraPosition _kInitialPosition = CameraPosition(
      target: Variables.currentPostion, zoom: 40.0, tilt: 0, bearing: 0);

  LatLng? currentSelectedLocation;
  String? currentSelectedLocName;

  int currentMapState = 0;

  PlacesDetailsResponse? details;

  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    mapController.setMapStyle(mapStyleJsonString);

    setState(() {
      log("this setstate");
      if (widget.location != null) {
        log("here");
        currentSelectedLocation =
            LatLng(widget.location!.lat, widget.location!.lng);
        mapController
            .animateCamera(CameraUpdate.newLatLng(currentSelectedLocation!));
      } else {
        log("not here");
        currentSelectedLocation = Variables.currentPostion;
      }
    });

    searchProviders();
  }

  Future<GeocodingResult?> decodeAddress(Location location) async {
    try {
      final geocoding = GoogleMapsGeocoding(
        apiKey: "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
      );

      GeocodingResponse response = await geocoding.searchByLocation(location);

      if (response.hasNoResults ||
          response.isDenied ||
          response.isInvalid ||
          response.isNotFound ||
          response.unknownError ||
          response.isOverQueryLimit) {
        log(response.errorMessage.toString());
        //_address = response.status;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ??
                  "Address not found, something went wrong!"),
            ),
          );
        }
        return null;
      }
      return response.results.first;
    } catch (e) {
      log(e.toString());
    }

    return null;
  }

  void searchProviders() async {
    setState(() {
      currentMapState = 1;
    });

    var response = await ApiService.getAvailableProviderList(
        "1",
        "1",
        currentSelectedLocation!.longitude.toString(),
        currentSelectedLocation!.longitude.toString());

    log(response!.data!.provider_data.toString());

    setState(() {
      currentMapState = 2;
    });
  }

  Widget _getBottomCard() {
    switch (currentMapState) {
      case 0:
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: AllColor.themeColor,
          child: Container(
            height: 50,
            width: double.infinity,
            child: Center(
              child: Text(
                "Search Service Provider around You",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        );
      case 1:
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: AllColor.themeColor,
          child: Container(
            height: 50,
            width: double.infinity,
            child: Center(
              child: Text(
                "Searching Service Provider...",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        );
      case 2:
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: AllColor.themeColor,
          child: InkWell(
            onTap: () async {
              // List<Placemark> placemarks = await placemarkFromCoordinates(
              //     currentSelectedLocation!.latitude,
              //     currentSelectedLocation!.longitude);
              // Navigator.pop(context, [
              //   currentSelectedLocation,
              //   "${placemarks[0].name}, ${placemarks[0].street}, ${placemarks[0].country},"
              // ]);

              GeocodingResult? address = await decodeAddress(Location(
                  lat: currentSelectedLocation!.latitude,
                  lng: currentSelectedLocation!.longitude));

              Navigator.pop(context, [address]);
            },
            child: Container(
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text(
                  "Go to Next Screen",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _kInitialPosition,
          zoomControlsEnabled: false,
          onMapCreated: _onMapCreated,
          onTap: (location) {
            log(location.toString());
            setState(() {
              currentSelectedLocation = location;
            });

            searchProviders();
          },
          markers: currentSelectedLocation != null
              ? {
                  Marker(
                    markerId: MarkerId('0'),
                    position: currentSelectedLocation!,
                    // icon: BitmapDescriptor.,
                    infoWindow: InfoWindow(
                      title: 'My Location',
                      snippet: '',
                    ),
                  )
                }
              : {},
        ),
        Positioned(
          top: 30.0,
          left: 5.0,
          right: 5.0,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Container(
              height: 50,
              width: double.infinity,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: VerticalDivider(
                      thickness: 1.0,
                    ),
                  ),
                  Expanded(
                      child: GestureDetector(
                          child: Text(currentSelectedLocName ??
                              "Search Visiting Address..."),
                          onTap: () async {
                            var place = await PlacesAutocomplete.show(
                                context: context,
                                apiKey:
                                    "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
                                mode: Mode.overlay,
                                types: [],
                                strictbounds: false,
                                components: [
                                  Component(Component.country, "bd")
                                ],
                                onError: (err) {
                                  print(err);
                                });

                            if (place == null) return;

                            GoogleMapsPlaces _places = GoogleMapsPlaces(
                              apiKey: "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
                            );

                            details = await _places
                                .getDetailsByPlaceId(place.placeId!);

                            final lat = details!.result.geometry!.location.lat;
                            final lng = details!.result.geometry!.location.lng;

                            mapController.animateCamera(
                                CameraUpdate.newLatLng(LatLng(lat, lng)));

                            setState(() {
                              currentSelectedLocation = LatLng(lat, lng);
                              currentSelectedLocName =
                                  details!.result.formattedAddress;
                            });

                            searchProviders();
                          })),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {},
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: _getBottomCard(),
        ),
        Positioned(
          right: 10,
          bottom: 80,
          child: FloatingActionButton(
            backgroundColor: AllColor.themeColor,
            child: Icon(Icons.my_location),
            onPressed: () {},
          ),
        )
      ],
    ));
  }
}


// return MapLocationPicker(
//         topCardColor: Colors.white70,
//         bottomCardColor: Colors.pinkAccent,
//         currentLatLng: Variables.currentPostion,
//         desiredAccuracy: LocationAccuracy.high,
//         apiKey: "AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY",
//         onNext: (GeocodingResult? result) async {
//           await DataControllers.to.getProviderList(
//               "1",
//               "1",
//               Variables.currentPostion.longitude.toString(),
//               Variables.currentPostion.latitude.toString());

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (cp) =>
//                   OrderConfirmPage(result: result!, orderType: "Long Term"),
//             ),
//           );
//         });