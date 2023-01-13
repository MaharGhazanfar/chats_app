import 'package:chats_app/screen/dashBoard.dart';
import 'package:chats_app/screen/login_screen.dart';
import 'package:chats_app/utils/const_value.dart';
import 'package:chats_app/utils/service_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  /// firebase initialize.......................................
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// sharePreference initialize.......................................
  ConstValue.prefs = await SharedPreferences.getInstance();

  ///  initialized notification ...................................

  final service = LocalNotificationService();
  await service.init();

  var per = await FirebaseMessaging.instance.requestPermission();

  if (per.authorizationStatus == AuthorizationStatus.authorized) {
    print('...........................Notification is initialized!!!!!!!');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      print('.............message recienved ....................................');
      if (message.notification != null) {
        service.showNotification(
            id: 12,
            title: message.notification!.title!,
            body: message.notification!.body!);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {});
  }

  runApp(const MyChatApp());
}

class MyChatApp extends StatefulWidget {
  const MyChatApp({Key? key}) : super(key: key);

  @override
  State<MyChatApp> createState() => _MyChatAppState();
}

class _MyChatAppState extends State<MyChatApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen.navigate(
        fit: BoxFit.fill,
        isLoading: false,
        startAnimation: 'movement',
        name: 'assets/mobile.riv', next: (context) =>
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.hasData) {
                return const DashBoard();
              } else {
                return const LoginScreen();
              }
            },
          ),)
    );
  }
}

