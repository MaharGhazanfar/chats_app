import 'package:chats_app/model_classes/model_user_info_status.dart';
import 'package:chats_app/screen/otp_screen.dart';
import 'package:chats_app/utils/const_value.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../state_management_controller/dart/timer_controller.dart';

///   null check validation  for textField..........................................
String? nullValidation(String? value) {
  if (value!.isEmpty) {
    return 'required';
  } else {
    return null;
  }
}

///   phone number check validation  for textField ..........................................
String? phoneNumberValidation(String? value) {
  if (value!.isNotEmpty) {
    if (value.length == 13) {
      if (value.startsWith('+923')) {
        return null;
      } else {
        return 'Number Must Start With +92...';
      }
    } else {
      return 'InValid phone number';
    }
  } else {
    return 'required';
  }
}

///   number verification with firebase ..................................

final TimerController timerController = Get.put(TimerController());

phoneVerification(
    {RoundedLoadingButtonController? roundController,
    String? statusForReSend,
    required BuildContext context}) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: ConstValue.prefs!.getString(ConstValue.userNumber)!,
    verificationCompleted: (PhoneAuthCredential credential) async {},
    verificationFailed: (FirebaseAuthException e) async {},
    codeSent: (String verificationId, int? resendToken) async {
      timerController.verificationCode = verificationId.obs;

      if (roundController != null) {
        roundController.reset();
      }

      if (statusForReSend == null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const OTPScreen()));
      }
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      print(
          '..........verification time out......$verificationId................');
    },
  );
}

///   update online status ..................................

void updateUserStatus({required String onlineStatus}) async {
  FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
      .update({
    ModelUserInfoStatus.lastSeenKEy: DateTime.now().toString(),
    ModelUserInfoStatus.onlineStatusKEy: onlineStatus
  });
}
