import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chats_app/model_classes/model_msg_send.dart';
import 'package:chats_app/model_classes/model_user_info_status.dart';
import 'package:chats_app/utils/const_value.dart';
import 'package:chats_app/utils/service_notification.dart';
import 'package:chats_app/utils/utils.dart';
import 'package:chats_app/widget/single_item_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../state_management_controller/dart/send_btn_size_controller.dart';
import '../utils/uploading_data.dart';
import '../utils/validation.dart';
import '../widget/bottom_sheet.dart';
import '../widget/loading_for_uploading.dart';

class ChatScreen extends StatefulWidget {
  final String number;
  final String name;

  const ChatScreen({Key? key, required this.number, required this.name})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>   with WidgetsBindingObserver {
  TextEditingController msgController = TextEditingController();

  final SendBtnSizeController sendBtnSizeController =
      Get.put(SendBtnSizeController());
  AudioPlayer? player;
  String currentAudioPath = '';
  final record = Record();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print(
          '...............................resumed........................................');
      updateUserStatus(onlineStatus: ConstValue.onlineStatus);
    } else {
      print(
          '...............................dipose........................................');
      updateUserStatus(onlineStatus: ConstValue.offlineStatus);
    }
  }

  @override
  void initState() {
    super.initState();
    record.hasPermission();
    WidgetsBinding.instance.addObserver(this);
    updateUserStatus(onlineStatus: ConstValue.onlineStatus);
    Future.delayed(
      const Duration(),
      () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
    seenMsgOtherUser(number: widget.number);
  }

  @override
  void dispose() {

    updateUserStatus(onlineStatus: ConstValue.offlineStatus);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    if (player != null) {
      player!.release();
      player!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (player != null) {
          player!.release();
          player!.dispose();
        }
        FirebaseFirestore.instance
            .collection(ConstValue.userCollection)
            .doc(widget.number)
            .collection(ConstValue.personalChatCollection)
            .doc(ConstValue.prefs!.getString(ConstValue.userNumber)!)
            .update({
          ModelUserInfoStatus.lastSeenKEy: DateTime.now().toString(),
          ModelUserInfoStatus.onlineStatusKEy: ConstValue.offlineStatus
        });
        return true;
      },
      child: Scaffold(
        backgroundColor: ConstValue.backgroundColor,
        appBar: AppBar(
          backgroundColor: ConstValue.frontColor,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(ConstValue.userCollection)
                          .doc(widget.number)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!.data()![
                                      ModelUserInfoStatus.onlineStatusKEy] ==
                                  ConstValue.onlineStatus
                              ? const Text(
                                  'online',
                                  style: TextStyle(fontSize: 12),
                                )
                              : Text(
                                  'Last seen ${DateFormat('d MMM,').add_jm().format(DateTime.parse(snapshot.data!.data()![ModelUserInfoStatus.lastSeenKEy]))}',
                                  style: const TextStyle(fontSize: 12),
                                );
                        } else {
                          return const SizedBox();
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),

        /// body of screen.............................................................................
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Column(
            children: [
              ///     chart portion .............................................................................
              Flexible(
                flex: 9,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(ConstValue.userCollection)
                      .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
                      .collection(ConstValue.personalChatCollection)
                      .doc(widget.number)
                      .collection(ConstValue.privateChatCollection)
                      .orderBy(ModelMsgSend.sendTimeKEy, descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      return ListView.builder(
                        reverse: true,

                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return SingleItemView(
                            snap: snapshot.data!.docs[index].data(),

                            key: UniqueKey(),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('There is no Chat'));
                    }
                  },
                ),
              ),

              ///     TextField for sending msg  .............................................................................
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 8,
                    child: Card(
                      color: ConstValue.frontColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: TextField(
                          controller: msgController,
                          autofocus: true,
                          onChanged: (value) {
                            sendBtnSizeController.textFieldValue.value = value;
                          },
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Message",
                            suffix: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (builder) => bottomSheet(
                                              context: context,
                                              number: widget.number));
                                    },
                                    child: const Icon(
                                      Icons.attach_file,
                                      color: Colors.white,
                                    )),

                                /// camera button  for image ...........................................................
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: InkWell(
                                      onTap: () async {
                                        await mediaImageUploading(
                                            context: context,
                                            number: widget.number,
                                            mediaImageSource:
                                                ImageSource.camera);
                                      },
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      )),
                                )
                              ],
                            ),
                            hintStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///  send  button for sms ...............................................................
                  Flexible(
                    flex: 2,
                    child: Obx(
                      () => Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: sendBtnSizeController.textFieldValue.value != ''
                            ? InkWell(
                                onTap: () async {
                                  if (msgController.text.isNotEmpty) {
                                    sendDataTOServer(
                                        number: widget.number,
                                        source: ConstValue.msgSource,
                                        messageURL:
                                            msgController.text.toString());

                                    sendingNotification(number: widget.number, body:msgController.text.toString() );

                                    msgController.clear();
                                    sendBtnSizeController.textFieldValue.value =
                                        msgController.text.toString();


                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  alignment: Alignment.center,
                                  decoration:  BoxDecoration(
                                      color: ConstValue.frontColor,
                                      shape: BoxShape.circle),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              )

                            ///      voice send button .................................................
                            : GestureDetector(
                                onLongPressEnd: (value) async {
                                  bool isRecording = await record.isRecording();
                                  if (isRecording) {
                                    record.stop();
                                  }

                                  if (!mounted) return;
                                  LoadingForUpload.onLoading(context);

                                  sendBtnSizeController.changeInSize(
                                      status: 'reverse');

                                  var urlVoice = await uploadFileToFireStorage(
                                      path: currentAudioPath,
                                      source: ConstValue.voiceSource);

                                  await DefaultCacheManager()
                                      .getSingleFile(urlVoice);

                                  await sendDataTOServer(
                                      number: widget.number,
                                      source: ConstValue.voiceSource,
                                      messageURL: urlVoice);

                                  sendingNotification(number: widget.number, body:ConstValue.voiceSource );

                                  if (!mounted) return;
                                  LoadingForUpload.hideDialog(context);
                                },
                                onLongPressStart: (start) async {
                                  sendBtnSizeController.changeInSize(
                                      status: 'forward');
                                  if (await record.hasPermission()) {
                                    Directory tempDir =
                                        await getTemporaryDirectory();
                                    String tempPath = tempDir.path;
                                    currentAudioPath =
                                        '$tempPath/${DateTime.now().millisecondsSinceEpoch}';
                                    await record.start(
                                      path: currentAudioPath,
                                      encoder: AudioEncoder.aacLc, // by default
                                      bitRate: 128000, // by default
                                    );
                                  }
                                },
                                child: Obx(
                                  () => AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    curve: Curves.bounceOut,
                                    height: sendBtnSizeController
                                        .voiceButtonHeight
                                        .toDouble(),
                                    width: sendBtnSizeController
                                        .voiceButtonWidth
                                        .toDouble(),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: ConstValue.frontColor,
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }
}
