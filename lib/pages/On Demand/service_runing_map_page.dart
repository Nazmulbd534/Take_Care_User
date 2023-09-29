import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/pages/On%20Demand/live_order_status.dart';
import 'package:takecare_user/pages/home_page.dart';
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
  final Map<String, dynamic>? details;
  int orderID;
  DestinationMapPage({
    Key? key,
    required this.invoiceId,
    required this.details,
    required this.orderID,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orderInformation != null
          ? LiveMap(
              orderID: widget.orderID,
              invoiceId: widget.invoiceId,
              details: widget.details,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class LiveMap extends StatefulWidget {
  String invoiceId;
  final Map<String, dynamic>? details;
  int orderID;
  LiveMap(
      {super.key,
      required this.invoiceId,
      required this.orderID,
      required this.details});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  List<LatLng> polylineCoordinates = [
    LatLng(
        Variables.currentPostion.latitude, Variables.currentPostion.longitude),
  ];

  List<Polyline> polyLines = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDPCbC2zItcRglbDZFIxzObIoSTkMA4xOo', // Your Google Map Key
      PointLatLng(
        Variables.currentPostion.latitude,
        Variables.currentPostion.longitude,
      ),
      PointLatLng(
        double.parse(orderInformation!["data"]["provider"]["latitude"]),
        double.parse(orderInformation!["data"]["provider"]["longitude"]),
      ),
    );
    log(result.points.toString(), name: "Polypoints");
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {
        log(polylineCoordinates.toString(), name: "Polyline");
      });
    }
  }

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
    getPolyPoints();
    log("${widget.invoiceId}", name: "live map");
    // rootBundle.loadString('assets/map/map_style.txt').then((string) {
    //   _mapStyle = string;
    // });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/images/nurse.png')
        .then((value) => providerIcon = value);
    initLocationUpdate();

    PusherService.channel.bind('order-update-event', (event) {
      log("Order update Event" + event!.data.toString(),
          name: "PusherService test1");
      Map<String, dynamic> data = jsonDecode(event.data!);
      if (data["message"]["status"] == 5) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                  orderID: widget.orderID,
                  invoiceID: widget.invoiceId,
                  details: widget.details),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("orders")
            .doc(
              widget.invoiceId,
            )
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data["provider"]["location"];

          return Scaffold(
            bottomSheet: Container(
              height: 160,
              color: Colors.white,
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  child: CachedNetworkImage(
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                    imageUrl: widget.details!["data"]
                                                    ["service_request"][0]
                                                ["provider"]["profile_photo"] ==
                                            null
                                        ? 'https://thumbs.dreamstime.com/b/man-profile-cartoon-smiling-round-icon-vector-illustration-graphic-design-135443422.jpg'
                                        : widget.details!["data"]
                                                ["service_request"][0]
                                                ["provider"]["profile_photo"]
                                            .toString(),
                                    placeholder: (context, url) =>
                                        Image.asset('assets/images/baby.png'),
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/images/baby.png'),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -7.0,
                                child: Container(
                                    alignment: Alignment.center,
                                    height: dynamicSize(.05),
                                    width: dynamicSize(0.13),
                                    //color: Colors.red,
                                    decoration: BoxDecoration(
                                      color: AllColor.white_yeo,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      "${widget.details!["data"]["service_request"][0]["provider"]["latitude"] == null ? (0).toString() : (Geolocator.distanceBetween(double.parse(widget.details!["data"]["service_request"][0]["provider"]["latitude"]), double.parse(widget.details!["data"]["service_request"][0]["provider"]["longitude"]), Variables.currentPostion.latitude, Variables.currentPostion.longitude) / 1000).toStringAsFixed(1)} km",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.green),
                                    )),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  widget.details!["data"]["service_request"][0]
                                      ["provider"]["full_name"],
                                  style: TextStyle(
                                      fontSize: dynamicSize(0.05),
                                      color: AllColor.themeColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      /*●*/
                                      Text(widget.details!["data"]
                                              ["service_request"][0]["provider"]
                                          ["speciality"]["speciality_name"]),
                                      const Text(" • 9 Patient Served"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            color: Colors.grey[200],
                          ),
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: const TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.chat,
                                ),
                                hintText: "Write message here"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Stack(
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
                        data["lat"],
                        data["long"],
                      ),
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
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                      color: AllColor.themeColor,
                      width: 6,
                    ),
                  },
                ),
              ],
            ),
          );
        });
  }
}
