import 'dart:io';
import 'package:chats_app/utils/const_value.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import '../screen/show_all_contact_to_select.dart';
import '../utils/service_notification.dart';
import '../utils/uploading_data.dart';
import '../utils/utils.dart';
import 'loading_for_uploading.dart';

Widget bottomSheet({required BuildContext context, required number}) {
  return SizedBox(
    height: 280,
    width: MediaQuery.of(context).size.width,
    child: Card(
      margin: const EdgeInsets.all(18.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                            allowedExtensions: ['doc', 'pdf', 'excel'],
                            type: FileType.custom);
                    if (result != null) {
                      () {
                        LoadingForUpload.onLoading(context);
                      }();
                      File file = File(result.files.single.path!);
                      var url = await uploadFileToFireStorage(
                          path: file.path, source: ConstValue.docSource);
                      await DefaultCacheManager().getSingleFile(url);
                      sendDataTOServer(
                          number: number,
                          source: ConstValue.docSource,
                          messageURL: url);
                      sendingNotification(number: number, body:ConstValue.docSource );
                      () {
                        LoadingForUpload.hideDialog(context);
                      }();
                    }
                  },
                  child: iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                ),
                InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await mediaImageUploading(
                          context: context,
                          number: number,
                          mediaImageSource: ImageSource.camera);
                      sendingNotification(number: number, body:ConstValue.imageSource );
                    },
                    child:
                        iconCreation(Icons.camera_alt, Colors.pink, "Camera")),
                InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await mediaImageUploading(
                          context: context,
                          number: number,
                          mediaImageSource: ImageSource.gallery);
                      sendingNotification(number: number, body:ConstValue.imageSource );
                    },
                    child: iconCreation(
                        Icons.insert_photo, Colors.purple, "Gallery")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(type: FileType.audio);
                      if (result != null) {
                        () {
                          LoadingForUpload.onLoading(context);
                        }();
                        File file = File(result.files.single.path!);
                        var url = await uploadFileToFireStorage(
                            path: file.path, source: ConstValue.voiceSource);
                        await DefaultCacheManager().getSingleFile(url);
                        sendDataTOServer(
                            number: number,
                            source: ConstValue.voiceSource,
                            messageURL: url);

                        sendingNotification(number: number, body:ConstValue.voiceSource );
                        () {
                          LoadingForUpload.hideDialog(context);
                        }();
                      }
                    },
                    child: iconCreation(Icons.headset, Colors.orange, "Audio")),
                InkWell(
                    onTap: () async {

                      () {
                        Navigator.pop(context);
                        LoadingForUpload.onLoading(context);
                      }();

                      LocationData locationData = await getCurrentLocation();

                      List location = [
                        locationData.latitude,
                        locationData.longitude
                      ];
                      sendDataTOServer(
                          number: number,
                          source: ConstValue.locationSource,
                          messageURL: '',
                          currentLocation: location);

                      sendingNotification(number: number, body:ConstValue.locationSource );

                      () {
                        LoadingForUpload.hideDialog(context);
                      }();
                    },
                    child: iconCreation(
                        Icons.location_pin, Colors.teal, "Location")),
                InkWell(
                    onTap: () async {
                      Navigator.pop(context);

                      var numberInfo = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShowAllContact(),
                          ));

                      sendDataTOServer(
                          number: number,
                          source: ConstValue.msgSource,
                          messageURL: ' ${numberInfo[0]} \n ${numberInfo[1]}');

                      sendingNotification(number: number, body:ConstValue.contactSource );
                    },
                    child: iconCreation(Icons.person, Colors.blue, "Contact")),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget iconCreation(IconData icons, Color color, String text) {
  return Column(
    children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: Icon(
          icons,
          // semanticLabel: "Help",
          size: 29,
          color: Colors.white,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            // fontWeight: FontWeight.w100,
          ),
        ),
      )
    ],
  );
}
