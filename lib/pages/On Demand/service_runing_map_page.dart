import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:takecare_user/public_variables/variables.dart';
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

  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyB5x56y_2IlWhARk8ivDevq-srAkHYr9HY', // Your Google Map Key
      PointLatLng(
        double.parse(orderInformation!["data"]["latitude"]),
        double.parse(orderInformation!["data"]["longitude"]),
      ),
      PointLatLng(
        double.parse(orderInformation!["data"]["latitude"]),
        double.parse(orderInformation!["data"]["longitude"]),
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

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
  Widget _arrivedMgsWidget() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Great!',
              style: TextStyle(
                  fontSize: dynamicSize(.05), fontWeight: FontWeight.bold)),
          SizedBox(height: dynamicSize(.02)),
          Icon(LineAwesomeIcons.check_circle,
              color: Colors.green, size: dynamicSize(.12)),
          SizedBox(height: dynamicSize(.02)),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style:
                  TextStyle(fontSize: dynamicSize(.035), color: AllColor.black),
              children: <TextSpan>[
                TextSpan(
                    text: 'You have safely arrived at\n\n',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: dynamicSize(.04))),
                // TextSpan(text: '${Variables.liveRequestResponse.bookingAddress}'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _startService = true;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Start Service')],
            ),
          )
        ],
      );

  Widget _startServiceUI() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Service Since', style: TextStyle(fontSize: dynamicSize(.045))),
          Divider(color: Colors.grey, thickness: 4),
          SizedBox(height: dynamicSize(.04)),

          ///Timer
          ClockTimeWidget(
            callback: (data) {
              serviceTime = data.toString();
            },
          ),
          SizedBox(height: dynamicSize(.04)),

          ElevatedButton(
              onPressed: () async {
                // await FirebaseFirestore.instance
                //     .collection('request')
                //     .doc(Variables.liveRequestResponse.id.toString())
                //     .update({
                //   'status': Variables.orderStatusData[4].statusCode,
                // });
                // setState(() {
                //   _finished = true;
                // });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Finish')],
              ))
        ],
      );

  Widget _finishedUI() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ///top header
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Service Seeker',
                  style: TextStyle(
                      fontSize: dynamicSize(.04), color: AllColor.black)),
            ],
          ),
          SizedBox(height: dynamicSize(.02)),

          ///Photo, Name, Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ///Left Section
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ///Image
                    Container(
                      alignment: Alignment.center,
                      height: dynamicSize(.16),
                      width: dynamicSize(.16),
                      decoration: BoxDecoration(
                        color: AllColor.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person,
                          color: Colors.white, size: dynamicSize(.15)),
                    ),
                    SizedBox(width: dynamicSize(.04)),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: dynamicSize(.04),
                                  color: AllColor.black),
                              children: <TextSpan>[
                                // TextSpan(
                                //     text: Variables.liveRequestResponse.sender_name,
                                //     style: TextStyle(
                                //         fontWeight:
                                //         FontWeight.bold)),
                                // TextSpan(text: ' on behalf of\n'),
                                // TextSpan(
                                //     text: Variables.liveRequestResponse.sender_name,
                                //     style: TextStyle(
                                //         fontWeight:
                                //         FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              ///Right Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('',
                      style: TextStyle(
                          fontSize: dynamicSize(.04),
                          color: AllColor.black,
                          fontWeight: FontWeight.bold)),
                  //SizedBox(height: dynamicSize(.005)),
                  Text('',
                      style: TextStyle(
                          fontSize: dynamicSize(.04),
                          color: AllColor.black,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          SizedBox(height: dynamicSize(.04)),
          Divider(color: Colors.grey, thickness: 3),

          Text('Cash Payment Service',
              style: TextStyle(
                  color: AllColor.pink_button,
                  fontWeight: FontWeight.bold,
                  fontSize: dynamicSize(.045))),
          SizedBox(height: dynamicSize(.04)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Service Length',
                  style: TextStyle(fontSize: dynamicSize(.04))),
              Text(serviceTime.toString(),
                  style: TextStyle(fontSize: dynamicSize(.04))),
            ],
          ),
          SizedBox(height: dynamicSize(.02)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bill (Details)',
                  style: TextStyle(fontSize: dynamicSize(.04))),
              Text('', style: TextStyle(fontSize: dynamicSize(.04))),
            ],
          ),
          SizedBox(height: dynamicSize(.04)),

          ElevatedButton(
              onPressed: () {
                // Get.to(()=>PaymentReceivedPage());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Payment Received')],
              ))
        ],
      );

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
      controller.animateCamera(CameraUpdate.newCameraPosition(nepPos));
    });
  }

  @override
  void initState() {
    super.initState();
    initLocationUpdate();
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
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(data["lat"], data["long"]),
                  zoom: 14,
                ),
                // markers: {
                //   Marker(
                //     markerId: const MarkerId("currentLocation"),
                //     position: LatLng(
                //         currentLocation!.latitude!, currentLocation!.longitude!),
                //   ),
                //   Marker(
                //     markerId: MarkerId("source"),
                //     position: LatLng(
                //         currentLocation!.latitude!, currentLocation!.longitude!),
                //   ),
                //   Marker(
                //     markerId: MarkerId("destination"),
                //     position: LatLng(
                //         double.parse(orderInformation!["data"]["latitude"]),
                //         double.parse(orderInformation!["data"]["latitude"])),
                //   ),
                // },
                // polylines: {
                //   Polyline(
                //     polylineId: const PolylineId("route"),
                //     points: polylineCoordinates,
                //     color: const Color(0xFF7B61FF),
                //     width: 6,
                //   ),
                // },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),

              ///Cancel Button
              Positioned(
                top: 40,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade400,
                  child: IconButton(
                      onPressed: () => Get.back(),
                      splashRadius: dynamicSize(.065),
                      icon: Icon(LineAwesomeIcons.times,
                          color: AllColor.themeColor, size: dynamicSize(.065))),
                ),
              ),

              ///Bottom
              _arrived
                  ? Positioned(
                      bottom: 0.0,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              )),
                          padding: EdgeInsets.all(dynamicSize(0.04)),
                          width: MediaQuery.of(context).size.width,
                          child: _startService
                              ? _finished
                                  ? _finishedUI()
                                  : _startServiceUI()
                              : _arrivedMgsWidget()),
                    )
                  : Positioned(
                      bottom: 0.0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(dynamicSize(.04)),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///top header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('',
                                    style: TextStyle(
                                        fontSize: dynamicSize(.04),
                                        color: AllColor.black)),

                                /// 35 min to go
                                Text('',
                                    style: TextStyle(
                                        fontSize: dynamicSize(.04),
                                        color: AllColor.black)),
                              ],
                            ),

                            SizedBox(height: dynamicSize(.02)),

                            ///Photo, Name, Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ///Left Section
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ///Image
                                      Container(
                                        alignment: Alignment.center,
                                        height: dynamicSize(.16),
                                        width: dynamicSize(.16),
                                        decoration: BoxDecoration(
                                          color: AllColor.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.person,
                                            color: Colors.white,
                                            size: dynamicSize(.15)),
                                      ),

                                      SizedBox(width: dynamicSize(.04)),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                    fontSize: dynamicSize(.04),
                                                    color: AllColor.black),
                                                children: <TextSpan>[
                                                  // TextSpan(
                                                  //     text: '${Variables.liveRequestResponse.sender_name}',
                                                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                                                  // TextSpan(text: ' on behalf of\n'),
                                                  // TextSpan(
                                                  //     text: '${Variables.liveRequestResponse.sender_name}',
                                                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                ///Right Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('',
                                        style: TextStyle(
                                            fontSize: dynamicSize(.04),
                                            color: AllColor.black,
                                            fontWeight: FontWeight.bold)),
                                    //SizedBox(height: dynamicSize(.005)),
                                    Text('',
                                        style: TextStyle(
                                            fontSize: dynamicSize(.04),
                                            color: AllColor.black,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ],
                            ),

                            SizedBox(height: dynamicSize(.04)),

                            Text(
                                'You can connect each other through free messaging',
                                style: TextStyle(fontSize: dynamicSize(.035))),

                            SizedBox(height: dynamicSize(.04)),

                            ///Message
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onTap: () {
                                      // Get.to(() => MessagePage());
                                    },
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        fillColor: AllColor.textFieldColor,
                                        filled: true,
                                        contentPadding: EdgeInsets.all(5),
                                        isDense: true,
                                        prefixIcon: Icon(
                                            LineAwesomeIcons.comment_dots,
                                            size: dynamicSize(.07),
                                            color: Colors.grey.shade700),
                                        // prefixIconConstraints: BoxConstraints.loose(MediaQuery.of(context).size),
                                        hintText: 'Write Message...',
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50)),
                                        )),
                                  ),
                                ),
                                SizedBox(width: 8),

                                ///New Message
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AllColor.button_color,
                                      radius: 18,
                                      child: Text('',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    Positioned(
                                      right: 0.0,
                                      top: 0.0,
                                      child: CircleAvatar(
                                          radius: 3.5,
                                          backgroundColor: AllColor.themeColor),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _arrived = true;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text('Arrived')],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
            ],
          );
        });
  }
}
