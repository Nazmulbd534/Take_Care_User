import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:takecare_user/services/pusher_service.dart';

class LiveOrderStatus extends StatefulWidget {
  const LiveOrderStatus({super.key});

  @override
  State<LiveOrderStatus> createState() => _LiveOrderStatusState();
}
// [PusherService test1] Order update Event{"message":{"service_order_id":52,"provider":230,"status":5}}

class _LiveOrderStatusState extends State<LiveOrderStatus> {
  int status = 6;
  @override
  void initState() {
    super.initState();
    PusherService.channel.bind('order-update-event', (event) {
      log("Order update Event" + event!.data.toString(),
          name: "PusherService test1");
      var dataJson = jsonDecode(event.data!);

      setState(() {
        status = dataJson["message"]["status"];
      });
    });
  }

  Widget timerPage() {
    return Center(
      child: Text("Timer"),
    );
  }

  Widget reviewPage() {
    return Center(
      child: Text("Review"),
    );
  }

  Widget getPage() {
    switch (status) {
      case 6:
        return timerPage();
      case 7:
        return reviewPage();
      default:
        return Text("Default Page");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(),
    );
  }
}
