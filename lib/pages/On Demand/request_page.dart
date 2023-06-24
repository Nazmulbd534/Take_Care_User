import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:takecare_user/controller/data_controller.dart';
import 'package:takecare_user/controllers/DataContollers.dart';
import 'package:takecare_user/model/provider/provider_data.dart';
import 'package:takecare_user/pages/On%20Demand/accepted_page.dart';
import 'package:takecare_user/pages/On%20Demand/cancel_page.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/public_variables/notifications.dart';
import 'package:takecare_user/public_variables/size_config.dart';
import 'package:takecare_user/public_variables/variables.dart';
import 'package:takecare_user/services/pusher_service.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  @override
  void initState() {
    super.initState();
    //DataController.dc.autoCancelRequest(widget.docId, widget.receiverId);

    PusherService.channel.bind('requestaccept-event', (event) {
      log(event!.data.toString(), name: "PusherService");
      log(DataControllers.to.userLoginResponse.value.data!.user!.id.toString(),
          name: "PusherService");
      var data = jsonDecode(event.data!);
      log(data["message"]["seeker"].toString(),
          name: "PusherService requestaccept-event");
      if (data["message"]["seeker"].toString() ==
          DataControllers.to.userLoginResponse.value.data!.user!.id
              .toString()) {
        if (data["message"]["status"] == "1") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AcceptedPage(
                      requestNumber: data["message"]["request_number"],
                      providerId: data["message"]["provider"])));
        } else if (data["message"]["status"] == "2") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CancelPage()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: AllColor.blue_light,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    // crossAxisAlignment:CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          //requestForCancel();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontFamily: 'Muli',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: dynamicSize(0.05)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: dynamicSize(0.2),
                  ),
                  CircleAvatar(
                    radius: 40,
                    // child: ClipOval(
                    //     child: Image.network(
                    //         "${widget.providerInfo.profilePhoto}")),
                  ),
                  SizedBox(
                    height: dynamicSize(0.1),
                  ),
                  Text(
                    "John Doe",
                    style: TextStyle(
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicSize(0.06),
                        color: Colors.white),
                  ),
                  Text(
                    "is on the way to accept the service. ",
                    style: TextStyle(
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicSize(0.05),
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: dynamicSize(0.5),
                  ),
                  Text(
                    "Please wait",
                    style: TextStyle(
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicSize(0.05),
                        color: Colors.white),
                  ),
                  Center(
                    child: LoadingAnimationWidget.prograssiveDots(
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
