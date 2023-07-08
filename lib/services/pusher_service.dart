import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:pusher_client/pusher_client.dart';
import '../controllers/DataContollers.dart';
import '../public_variables/variables.dart';

class PusherService {
  static String appId = "1611970";
  static String key = "4b45e750e635b95f3019";
  static String secret = "11f125c0925fcd324eef";
  static String cluster = "ap2";

  static late Channel channel;

  static PusherClient pusher = PusherClient(
    key,
    PusherOptions(
      cluster: cluster,
      auth: PusherAuth("https://api.takecare.ltd/pusher/broadcasting/auth",
          headers: {
            "Authorization": bearerToken,
          }),
    ),
    autoConnect: false,
    enableLogging: true,
  );

  static Future<void> connect() async {
    log("connect!", name: "PusherService");
    await pusher.connect();
    channel = pusher.subscribe(
        "private-takecare.${DataControllers.to.userLoginResponse.value.data!.user!.id.toString()}");

    log(channel.name, name: "pusher test");
    pusher.onConnectionStateChange((state) {
      log("previousState: ${state!.previousState}, currentState: ${state.currentState}",
          name: "PusherService");
    });

    pusher.onConnectionError((error) {
      log("error: ${error!.message}", name: "PusherService error");
    });
  }
}
