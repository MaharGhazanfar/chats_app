import 'dart:convert';
import 'package:chats_app/model_classes/model_user_info_status.dart';
import 'package:chats_app/utils/const_value.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class LocalNotificationService {
  LocalNotificationService();

  final localNotification = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    AndroidInitializationSettings androidSetting =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    InitializationSettings setting =
        InitializationSettings(android: androidSetting);

    await localNotification.initialize(setting,
        onSelectNotification: (value) {});
  }

  Future<NotificationDetails> notificationDetails() async {
    AndroidNotificationDetails details = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      playSound: true,
      priority: Priority.high,
      importance: Importance.high,
      channelDescription: 'Here am i',
    );

    return NotificationDetails(android: details);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    var details = await notificationDetails();
    await localNotification.show(id, title, body, details);
  }
}

void sendingNotification({required String number, required String body}) {
  var url = Uri.parse(ConstValue.sendPushNotificationAPI);

  print('.............message recienved ....................................');

  FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .doc(number)
      .get()
      .then(
    (value) {
      http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': ConstValue.severKey
        },
        body: jsonEncode(
          {
            "priority": "high",
            'to': value.data()![ModelUserInfoStatus.userTokenKey],
            "notification": {
              "body": body,
              "title": ConstValue.prefs!.getString(ConstValue.userName),
              "android_channel_id": "channelId"
            }
          },
        ),
      );
    },
  );
}
