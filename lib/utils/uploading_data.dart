import 'dart:io';
import 'package:chats_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model_classes/model_msg_send.dart';
import '../widget/loading_for_uploading.dart';
import 'const_value.dart';

Future<void> sendDataTOServer({
  required String number,
  required String source,
  required String messageURL,
  var currentLocation,
}) async {
  String userOnlineStatus = '';
  String checkOtherUserSeen = '';

  await checkOtherUserForOnline(number: number).then((value) {
    userOnlineStatus = value;
  });

  await checkOtherUserSeenMsg(number: number).then((value) {
    checkOtherUserSeen = value;
  });

  var ourStatusMsg = ModelMsgSend(
      sendTime: DateTime.now().toString(),
      deliverTime: userOnlineStatus == ConstValue.onlineStatus
          ? DateTime.now().toString()
          : '',
      seenTime: userOnlineStatus == ConstValue.onlineStatus &&
              checkOtherUserSeen == ConstValue.onlineStatus
          ? DateTime.now().toString()
          : '',
      message: source == ConstValue.msgSource ? messageURL : '',
      voiceURl: source == ConstValue.voiceSource ? messageURL : '',
      imageURl: source == ConstValue.imageSource ? messageURL : '',
      docURl: source == ConstValue.docSource ? messageURL  :   '',
      currentLocation: currentLocation ?? [],


      isRepliedMessage: '',
      repliedMessage: '',
      seenStatus: userOnlineStatus == ConstValue.onlineStatus &&
              checkOtherUserSeen == ConstValue.onlineStatus
          ? ConstValue.statusSeen
          : userOnlineStatus == ConstValue.onlineStatus
              ? ConstValue.statusDelivered
              : ConstValue.statusSend,
      isSendByMe: ConstValue.onlineStatus);

  FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
      .collection(ConstValue.personalChatCollection)
      .doc(number)
      .collection(ConstValue.privateChatCollection)
      .doc(DateTime.now().toString())
      .set(ourStatusMsg.toMap());

  var userStatusMsg = ModelMsgSend(
      sendTime: DateTime.now().toString(),
      deliverTime: userOnlineStatus == ConstValue.onlineStatus
          ? DateTime.now().toString()
          : '',
      seenTime: userOnlineStatus == ConstValue.onlineStatus &&
              checkOtherUserSeen == ConstValue.onlineStatus
          ? DateTime.now().toString()
          : '',
      message: source == ConstValue.msgSource ? messageURL : '',
      voiceURl: source == ConstValue.voiceSource ? messageURL : '',
      imageURl: source == ConstValue.imageSource ? messageURL : '',
      docURl: source == ConstValue.docSource ? messageURL  :   '',
      currentLocation: currentLocation ?? [],

      isRepliedMessage: '',
      repliedMessage: '',
      seenStatus: userOnlineStatus == ConstValue.onlineStatus &&
              checkOtherUserSeen == ConstValue.onlineStatus
          ? ConstValue.statusSeen
          : userOnlineStatus == ConstValue.onlineStatus
              ? ConstValue.statusDelivered
              : ConstValue.statusSend,
      isSendByMe: ConstValue.offlineStatus);

  FirebaseFirestore.instance
      .collection(ConstValue.userCollection)
      .doc(number)
      .collection(ConstValue.personalChatCollection)
      .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
      .collection(ConstValue.privateChatCollection)
      .doc(DateTime.now().toString())
      .set(userStatusMsg.toMap());
}

final storageRef = FirebaseStorage.instance.ref();

Future<String> uploadFileToFireStorage({
  required String path,
  required String source,
}) async {
  File file = File(path);

  var url = '';
  try {
    var upload = await storageRef
        .child('Data/$source')
        .child('${DateTime.now().millisecondsSinceEpoch}')
        .putFile(file);
    var snap = upload;

    url = await snap.ref.getDownloadURL();
  } on FirebaseException catch (e) {
    print(e);
  }

  return url;
}

Future<void> mediaImageUploading({
  required String number,
  required ImageSource mediaImageSource,
  required BuildContext context,
}) async {
  File imageFile = await pickImageFromMedia(mediaImageSource);
  () {
    LoadingForUpload.onLoading(context);
  }();

  String imageUrl = await uploadFileToFireStorage(
      path: imageFile.path, source: ConstValue.imageSource);
  sendDataTOServer(
      number: number, source: ConstValue.imageSource, messageURL: imageUrl);
  () {
    LoadingForUpload.hideDialog(context);
  }();
}
