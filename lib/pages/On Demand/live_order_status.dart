import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:takecare_user/services/pusher_service.dart';

class LiveOrderStatus extends StatefulWidget {
  const LiveOrderStatus({super.key});

  @override
  State<LiveOrderStatus> createState() => _LiveOrderStatusState();
}

class _LiveOrderStatusState extends State<LiveOrderStatus> {
  String statusText = "Event Updates: \n\n";

  @override
  void initState() {
    super.initState();
    PusherService.channel.bind('order-update-event', (event) {
      log("Order update Event" + event!.data.toString(),
          name: "PusherService test1");
      setState(() {
        statusText += "\n${event.data!}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(statusText),
        ],
      ),
    );
  }
}
