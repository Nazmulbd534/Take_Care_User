import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:takecare_user/controllers/language_controller.dart';
import 'package:takecare_user/pages/home_page.dart';
import 'package:takecare_user/pages/sign_in_page.dart';
import 'package:takecare_user/pages/signup/signup.dart';
import 'package:takecare_user/public_variables/all_colors.dart';
import 'package:takecare_user/services/pusher_service.dart';
import 'api_service/service.dart';
import 'controller/data_controller.dart';
import 'controllers/DataContollers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  ///Onclick listener
  NotificationService.display(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Get.put(DataController());
  Get.put(DataControllers());
  Get.put(LanguageController());

  /// Set Device orientation
  AllColor.portraitMood;
  HttpOverrides.global = new PostHttpOverrides();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _fcmInit();
    PusherService.connect();
  }

  Future<void> _fcmInit() async {
    FirebaseMessaging.instance.getInitialMessage();

    ///When App Running
    FirebaseMessaging.onMessage.listen((event) {
      if (kDebugMode) {
        print('!!FCM message Received!! (On Running)\n');
        print('Event: ${event.data}\n'
            'body: ${event.notification!.body}\n'
            'Message ID: ${event.messageId}\n');
      }
      NotificationService.display(event);
    });

    ///When App Minimized
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (kDebugMode) {
        print('!!FCM message Received (On Minimize)!!');
        print('Event: ${event.data}\n'
            'body: ${event.notification!.body}\n'
            'Message ID: ${event.messageId}\n');
      }
      NotificationService.display(event);
    });

    ///When App Destroyed
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (kDebugMode) {
        print('!!FCM message Received (On Destroy)!!');
      }
      if (value != null) {
        NotificationService.display(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Take Care',
      theme: AllColor.theme,
      debugShowCheckedModeBanner: false,
      home: const SignUp(),
    );
  }
}
