import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/pages/On%20Demand/live_order_status.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:takecare_user/public_variables/variables.dart';
import 'package:takecare_user/services/pusher_service.dart';
import 'package:takecare_user/widgets/clock_time_widget.dart';

Map<String, dynamic>? orderInformation;

Completer<GoogleMapController> _controller = Completer();
String serviceTime = '';
bool _arrived = false;
bool _startService = false;
bool _finished = false;

class DestinationMapPage extends StatefulWidget {
  String invoiceId;

  DestinationMapPage({
    Key? key,
    required this.invoiceId,
  }) : super(key: key);

  @override
  _DestinationMapPageState createState() => _DestinationMapPageState();
}

class _DestinationMapPageState extends State<DestinationMapPage> {
  void loadOrderInformation() async {
    orderInformation = await ApiService.fetchOrderInformation(widget.invoiceId);
    setState(() {});
  }

  void initState() {
    super.initState();
    loadOrderInformation();
  }

  // List<LatLng> polylineCoordinates = [];
  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     'AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY', // Your Google Map Key
  //     PointLatLng(
  //       double.parse(orderInformation!["data"]["latitude"]),
  //       double.parse(orderInformation!["data"]["longitude"]),
  //     ),
  //     PointLatLng(
  //       double.parse(orderInformation!["data"]["latitude"]),
  //       double.parse(orderInformation!["data"]["longitude"]),
  //     ),
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach(
  //       (PointLatLng point) => polylineCoordinates.add(
  //         LatLng(point.latitude, point.longitude),
  //       ),
  //     );
  //     setState(() {});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orderInformation != null
          ? LiveMap(invoiceId: widget.invoiceId)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class LiveMap extends StatefulWidget {
  String invoiceId;

  LiveMap({super.key, required this.invoiceId});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  String _mapStyle = "";
  void initLocationUpdate() async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('orders').doc(widget.invoiceId);

    reference.snapshots().listen((snapshot) async {
      log(snapshot.data().toString());
      CameraPosition nepPos = CameraPosition(
        target: LatLng(snapshot["provider"]["location"]["lat"],
            snapshot["provider"]["location"]["long"]),
        zoom: 14,
      
      );
    
      final GoogleMapController controller = await _controller.future;
    controller.setMapStyle(_mapStyle);
    
      controller.animateCamera(CameraUpdate.newCameraPosition(nepPos));
    });
  }
   BitmapDescriptor? providerIcon;
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map/map_style.txt').then((string) {
      _mapStyle = string;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/nurse.png')
        .then((value) => providerIcon = value);
    initLocationUpdate();

    PusherService.channel.bind('order-update-event', (event) {
      log("Order update Event" + event!.data.toString(),
          name: "PusherService test1");
      Map<String, dynamic> data = jsonDecode(event.data!);
      if (data["message"]["status"] == 5) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => LiveOrderStatus(),));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.invoiceId)
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data["provider"]["location"];

          return Stack(
            alignment: Alignment.center,
            children: [
              ///Google map
              GoogleMap(
                 onMapCreated: (GoogleMapController controller) {
                 controller.setMapStyle(_mapStyle);
                },
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(data["lat"], data["long"]),
                  zoom: 14.5,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("provider_loc"),
                    position: LatLng(
                        data["lat"], data["long"],),
                   icon: providerIcon!,
                  ),
                  // Marker(
                  //   markerId: MarkerId("source"),
                  //   position: LatLng(
                  //       currentLocation!.latitude!, currentLocation!.longitude!),
                  // ),
                  // Marker(
                  //   markerId: MarkerId("destination"),
                  //   position: LatLng(
                  //       double.parse(orderInformation!["data"]["latitude"]),
                  //       double.parse(orderInformation!["data"]["latitude"])),
                  // ),
                },
                // polylines: {
                //   Polyline(
                //     polylineId: const PolylineId("route"),
                //     points: polylineCoordinates,
                //     color: const Color(0xFF7B61FF),
                //     width: 6,
                //   ),
                // },
            
              ),
            ],
          );
        });
  }
}
