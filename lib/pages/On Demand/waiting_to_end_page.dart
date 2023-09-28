import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:takecare_user/pages/home_page.dart';
import 'package:takecare_user/services/pusher_service.dart';

import '../../public_variables/size_config.dart';

class WaitingToEndPage extends StatefulWidget {
  const WaitingToEndPage({Key? key}) : super(key: key);

  @override
  _WaitingToEndPageState createState() => _WaitingToEndPageState();
}

class _WaitingToEndPageState extends State<WaitingToEndPage> {
  @override
  void initState() {
    super.initState();
    PusherService.channel.bind('order-update-event', (event) {
      log("Order update Event" + event!.data.toString(),
          name: "PusherService test1");
      var dataJson = jsonDecode(event.data!);

      setState(() {
        var status = dataJson["message"]["status"];
        if (status == 9) {
          showDialog(
              context: context,
              builder: ((context) => AlertDialog(
                    content: Text("Order end"),
                  )));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Text("Waiting for the provider to end this order."),
          ),
        ));
  }
}
