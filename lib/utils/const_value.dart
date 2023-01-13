import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConstValue {
  /// firebase value ......................................
  static const String userCollection = 'ChillChat';
  static const String offlineStatus = 'false';
  static const String onlineStatus = 'true';
  static const String personalChatCollection = 'personalChat';
  static const String privateChatCollection = 'privateChat';
  static const String statusSend = 'send';
  static const String statusDelivered = 'delivered';
  static const String statusSeen = 'seen';

  ///   type of msg send .................................................
  static const String msgSource = 'msg';
  static const String voiceSource = 'audio';
  static const String imageSource = 'image';
  static const String docSource = 'doc';
  static const String contactSource = 'contact';
  static const String locationSource = 'location';

  /// sharePreference value ..............................................
  static SharedPreferences? prefs;
  static const String userNumber = 'userNumber';
  static const String userName = 'userName';

  ///  notification   API ...............................

  static const sendPushNotificationAPI = 'https://fcm.googleapis.com/fcm/send';
  static const severKey =
      'key=AAAAdTqIzj4:APA91bF9CUsGaaUI3Vy3SWk2GAo5abCT0nDxQ3rxhcDJJ1vQx-iO9LJJPWCrx_wWb_tNaxw92l4bd_tbMm9_oiaWMXM9_uJnJPYVHTTM97_o_eDBnh5WaouhgSwp8U03G-OaVjpDOIAZ';


  /// colors theming .........................................
  static const double  btnElevation = 12;
   static  Color   backgroundColor  =  Colors.indigo.shade200;
   static  Color   textFillColor  =  Colors.indigo.shade100;
   static  Color   frontColor  =  Colors.indigo.shade400;
}
