import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:takecare_user/api_service/ApiService.dart';
import 'package:takecare_user/pages/On%20Demand/service_runing_map_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> orderInformation;

  const ChatPage({super.key, required this.orderInformation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  types.User? user;
  List<types.Message> messages = [];

  bool isLoaded = false;

  void loadData() async {
    // log(orderInformation.toString(), name: "orderInformation");
    var user1 = orderInformation!["data"]["seeker_id"];
    var user2 = orderInformation!["data"]["provider_id"];

    user = types.User(id: user1.toString());

    var msgData = await ApiService.fetchMessages(user1, user2, user2);

    //log(msgData.toString());

    for (var msg in msgData) {
      var m = types.TextMessage(
        author: types.User(id: msg["sender_id"].toString()),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: msg["message"],
      );

      messages.insert(0, m);
    }

    setState(() {
      isLoaded = true;
    });
  }

  void addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  void sendMessage(String msg) {
    var m = types.TextMessage(
      author: user!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: msg,
    );

    addMessage(m);

    var user1 = orderInformation!["data"]["seeker_id"];
    var user2 = orderInformation!["data"]["provider_id"];

    ApiService.sendMessages(user1, user2, msg);
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                  orderInformation!["data"]["provider"]["profile_photo"]),
            ),
            SizedBox(
              width: 10,
            ),
            Text(orderInformation!["data"]["provider"]["full_name"])
          ],
        ),
      ),
      body: isLoaded
          ? Chat(
              theme: DefaultChatTheme(
                  sendButtonIcon: Icon(
                Icons.send,
                color: Colors.white,
              )),
              messages: messages,
              showUserAvatars: true,
              showUserNames: true,
              user: user!,
              onSendPressed: (msg) {
                sendMessage(msg.text);
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
