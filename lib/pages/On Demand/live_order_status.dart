import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:takecare_user/services/pusher_service.dart';

class LiveOrderStatus extends StatefulWidget {
  const LiveOrderStatus({super.key});

  @override
  State<LiveOrderStatus> createState() => _LiveOrderStatusState();
}
// [PusherService test1] Order update Event{"message":{"service_order_id":52,"provider":230,"status":5}}

class _LiveOrderStatusState extends State<LiveOrderStatus> {
  int status = 6;
    final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  @override
  void initState() {
    super.initState();
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         const Text("Service Running For"),
          const SizedBox(
            height: 20.0,
          ),

             Center(
                      child: StreamBuilder<int>(
                        stream: _stopWatchTimer.rawTime,
                        initialData: 0,
                        builder: (context, snap) {
                          final value = snap.data!;
                          final displayTime = StopWatchTimer.getDisplayTime(
                              value,
                              hours: true,
                              milliSecond: false,
                              );
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              displayTime,
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,),
                            ),
                          );
                        },
                      ),
                    ),
    

        ],
      ),
    );
  }

  Widget reviewPage() {
    return Center(
      child: Text("Review"),
    );
  }

   @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();  // Need to call dispose function.
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
