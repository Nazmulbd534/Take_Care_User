import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:pusher_client/pusher_client.dart';

class PusherService {
  static String appId = "1611970";
  static String key = "4b45e750e635b95f3019";
  static String secret = "11f125c0925fcd324eef";
  static String cluster = "ap2";

  static late Channel channel;
  static late Channel privateChannel;

  static PusherClient pusher = PusherClient(
    key,
    PusherOptions(
      cluster: cluster,
    ),
    autoConnect: false,
    enableLogging: true,
  );

  static Future<void> connect() async {
    log("connect!", name: "PusherService");
    await pusher.connect();
    channel = pusher.subscribe("takecare");

    log(channel.name, name: "pusher_log");
    pusher.onConnectionStateChange((state) {
      log("previousState: ${state!.previousState}, currentState: ${state.currentState}",
          name: "PusherService");
    });

    pusher.onConnectionError((error) {
      log("error: ${error!.message}", name: "PusherService error");
    });
  }

  static Future<void> initLocationUpdateChannel(String providerID) async {
    privateChannel = pusher.subscribe("private-takecare.${providerID}");
    return;
  }

  static void sendLocationUpdate(LatLng loc, String providerID) async {
    await privateChannel.trigger("locationUpdate",
        {"provider_id": providerID, "lat": loc.latitude, "lon": loc.longitude});
    log("Location Update sent for $providerID, data: ${loc.toString()}");
  }
}
