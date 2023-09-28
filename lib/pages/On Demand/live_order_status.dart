import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/pages/On%20Demand/waiting_to_end_page.dart';
import 'package:takecare_user/pages/On%20Demand/write_review_page.dart';
import 'package:takecare_user/services/pusher_service.dart';

import '../../public_variables/all_colors.dart';
import '../../public_variables/size_config.dart';
import '../../public_variables/variables.dart';

class LiveOrderStatus extends StatefulWidget {
  final String invoiceID;
  final int orderID;
  final Map<String, dynamic>? details;
  const LiveOrderStatus(
      {super.key,
      required this.invoiceID,
      required this.orderID,
      required this.details});

  @override
  State<LiveOrderStatus> createState() => _LiveOrderStatusState();
}
// [PusherService test1] Order update Event{"message":{"service_order_id":52,"provider":230,"status":5}}

class _LiveOrderStatusState extends State<LiveOrderStatus> {
  int status = 6;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  int total = 0;
  int price = 0;
  void countServices() {
    for (int i = 0;
        i <
            widget
                .details!["data"]["service_request"][0]["service_request_items"]
                .length;
        i++) {
      total++;
      price += int.parse(widget.details!["data"]["service_request"][0]
              ["service_request_items"][i]["service_price"]
          .toString());
    }
  }

  @override
  void initState() {
    super.initState();
    countServices();
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    PusherService.channel.bind('order-update-event', (event) {
      log("Order update Event" + event!.data.toString(),
          name: "PusherService test1");
      var dataJson = jsonDecode(event.data!);

      setState(() {
        status = dataJson["message"]["status"];
      });
    });
  }

  final value = StopWatchTimer.getMilliSecFromMinute(60);

  Widget timerPage() {
    return Scaffold(
      backgroundColor: AllColor.shado_color,
      appBar: AppBar(
        leading: const SizedBox(),
        centerTitle: true,
        backgroundColor: AllColor.themeColor,
        title: const Text(
          "Current Service",
          style: TextStyle(
            fontFamily: "Muli",
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4.0,
                child: Column(
                  children: [
                    Center(
                      child: StreamBuilder<int>(
                        stream: _stopWatchTimer.rawTime,
                        initialData: 0,
                        builder: (context, snap) {
                          final value = snap.data!;
                          final displayTime = StopWatchTimer.getDisplayTime(
                            value,
                            hours: true,
                            hoursRightBreak: " : ",
                            minuteRightBreak: " : ",
                            secondRightBreak: " : ",
                            milliSecond: false,
                          );
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  displayTime,
                                  style: const TextStyle(
                                    fontSize: 43,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.bold,
                                    color: AllColor.themeColor,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    const Text(
                                      "Hour",
                                      style: TextStyle(
                                        fontFamily: "Muli",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                    ),
                                    const Text(
                                      "Minute",
                                      style: TextStyle(
                                        fontFamily: "Muli",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.07,
                                    ),
                                    const Text(
                                      "Second",
                                      style: TextStyle(
                                        fontFamily: "Muli",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 120,
                      color: Colors.white,
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
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
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        imageUrl: widget.details!["data"]
                                                            ["service_request"]
                                                        [0]["provider"]
                                                    ["profile_photo"] ==
                                                null
                                            ? 'https://thumbs.dreamstime.com/b/man-profile-cartoon-smiling-round-icon-vector-illustration-graphic-design-135443422.jpg'
                                            : widget.details!["data"]
                                                    ["service_request"][0]
                                                    ["provider"]
                                                    ["profile_photo"]
                                                .toString(),
                                        placeholder: (context, url) =>
                                            Image.asset(
                                                'assets/images/baby.png'),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/baby.png'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      widget.details!["data"]["service_request"]
                                          [0]["provider"]["full_name"],
                                      style: TextStyle(
                                          fontSize: dynamicSize(0.05),
                                          color: AllColor.themeColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        children: const [
                                          /*●*/
                                          Text(
                                            "Has started the service",
                                            style: TextStyle(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController _reviewTextController = TextEditingController();

  Widget reviewPage() {
    return Scaffold(
      backgroundColor: AllColor.shado_color,
      appBar: AppBar(
        leading: const SizedBox(),
        centerTitle: true,
        backgroundColor: AllColor.themeColor,
        title: const Text(
          "Payment",
          style: TextStyle(
            fontFamily: "Muli",
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.centerStart,
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {},
          child: Text("Pay Online"),
        ),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Give Rating"),
                  content: Container(
                    child: TextField(
                      controller: _reviewTextController,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        debugPrint(widget.details.toString());
                        ApiService.addRatingToUser(
                            widget.invoiceID, _reviewTextController.text);
                        ApiService.changeOrderStatus(widget.orderID, 9);
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WaitingToEndPage()));
                      },
                      child: Text("Submit"),
                    )
                  ],
                );
              },
            );
          },
          child: Text("Pay Cash"),
        )
      ],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4.0,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: SizedBox(
                        height: 40.0,
                        width: 40.0,
                        child: Image.asset("assets/images/success.png"),
                      ),
                    ),
                    Container(
                      height: 105,
                      color: Colors.white,
                      child: Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
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
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        imageUrl: widget.details!["data"]
                                                            ["service_request"]
                                                        [0]["provider"]
                                                    ["profile_photo"] ==
                                                null
                                            ? 'https://thumbs.dreamstime.com/b/man-profile-cartoon-smiling-round-icon-vector-illustration-graphic-design-135443422.jpg'
                                            : widget.details!["data"]
                                                    ["service_request"][0]
                                                    ["provider"]
                                                    ["profile_photo"]
                                                .toString(),
                                        placeholder: (context, url) =>
                                            Image.asset(
                                                'assets/images/baby.png'),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/baby.png'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      widget.details!["data"]["service_request"]
                                          [0]["provider"]["full_name"],
                                      style: TextStyle(
                                          fontSize: dynamicSize(0.05),
                                          color: AllColor.themeColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        children: const [
                                          /*●*/
                                          Text(
                                            "Has finished services greatly",
                                            style: TextStyle(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Give Feedback",
                            style: TextStyle(
                              color: AllColor.themeColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15.0,
                        )
                      ],
                    ),
                    Container(
                      width: double.maxFinite,
                      color: const Color.fromARGB(33, 255, 204, 0),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Services ($total)",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Text(
                              "Total: $price /-",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              width: 10.0,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose(); // Need to call dispose function.
  }

  Widget getPage() {
    switch (status) {
      case 6:
        return timerPage();
      case 7:
        return reviewPage();
      default:
        return reviewPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(),
    );
  }
}
