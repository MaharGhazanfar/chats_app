import 'dart:io';
import 'package:chats_app/model_classes/model_msg_send.dart';
import 'package:chats_app/model_classes/model_user_info_status.dart';
import 'package:chats_app/utils/const_value.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

Future<List<Contact>> fetchContact() async {
  if (await FlutterContacts.requestPermission()) {
    List<Contact> contacts = await FlutterContacts.getContacts(
      deduplicateProperties: true,
      withProperties: true,
    );

    return contacts;
  } else {
    return [];
  }
}

Future<List<String>> fetchUserUID() async {
  List<String> userUIDS = [];

  var uid = await FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .get();

  for (int i = 0; i < uid.docs.length; i++) {
    userUIDS.add(uid.docs[i].id);
  }
  return userUIDS;
}

Future<List<String>> fetchPersonalChatUser() async {
  List<String> userPersonalUIDS = [];

  var uid = await FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .doc(ConstValue.prefs!.get(ConstValue.userNumber).toString())
      .collection(ConstValue.personalChatCollection)
      .get();

  for (int i = 0; i < uid.docs.length; i++) {
    userPersonalUIDS.add(uid.docs[i].id);
  }
  return userPersonalUIDS;
}

Future<void> seenMsgOtherUser({required String number}) async {
  await FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .doc(number)
      .get()
      .then((snap) {
    if (snap.data()![ModelUserInfoStatus.onlineStatusKEy] ==
        ConstValue.onlineStatus) {
      FirebaseFirestore.instance
          .collection(ConstValue.userCollection)
          .doc(number)
          .collection(ConstValue.personalChatCollection)
          .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
          .collection(ConstValue.privateChatCollection)
          .get()
          .then((snapShot) {
        for (int i = 0; i < snapShot.docs.length; i++) {
          if (snapShot.docs[i][ModelMsgSend.seenTimeKey].toString() == "") {
            String id = snapShot.docs[i].id;

            FirebaseFirestore.instance
                .collection(ConstValue.userCollection)
                .doc(number)
                .collection(ConstValue.personalChatCollection)
                .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
                .collection(ConstValue.privateChatCollection)
                .doc(id)
                .update(
              {
                ModelMsgSend.seenTimeKey: DateTime.now().toString(),
                ModelMsgSend.seenStatusKey: ConstValue.statusSeen,
              },
            );
          }
        }
      });
    }
  });
}


Future<String> checkOtherUserSeenMsg({required String number}) async {
  String otherUserSeenMsg = '';

  await FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
      .collection(ConstValue.personalChatCollection)
      .doc(number)
      .get()
      .then((snap) {
    otherUserSeenMsg = snap.data()![ModelUserInfoStatus.onlineStatusKEy];
  });

  return otherUserSeenMsg;
}

Future<String> checkOtherUserForOnline({required String number}) async {
  String checkOtherUserForOnline = '';

  await FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .doc(number)
      .get()
      .then((snap) {
    checkOtherUserForOnline = snap.data()![ModelUserInfoStatus.onlineStatusKEy];
  });

  return checkOtherUserForOnline;
}

Future<File> pickImageFromMedia(
    ImageSource imageSource,
    ) async {
  File? image;

  final ImagePicker picker = ImagePicker();

  final XFile? photo = await picker.pickImage(source: imageSource,maxHeight: 3000, maxWidth: 3000  );

  image = File(photo!.path);

  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: image.path,
    cropStyle: CropStyle.rectangle,
    maxHeight: 1500,
    maxWidth: 1500,
    compressQuality: 60,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false),
    ],
  );

  image = File(croppedFile!.path);

  return image;
}

Future<LocationData>  getCurrentLocation() async{
  Location location =  Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {

    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {

    }
  }

  locationData = await location.getLocation();

  print(locationData);

  return locationData;

}
