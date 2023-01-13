import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model_classes/model_msg_send.dart';
import '../utils/const_value.dart';

class SingleItemView extends StatefulWidget {
  final Map<String, dynamic> snap;

  const SingleItemView({Key? key, required this.snap}) : super(key: key);

  @override
  State<SingleItemView> createState() => _SingleItemViewState();
}

class _SingleItemViewState extends State<SingleItemView> {
  var isPlaying = false;
  var durationAudio = Duration.zero;
  var positionAudio = Duration.zero;

  AudioPlayer? player;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          widget.snap[ModelMsgSend.isSendByMeKey] == ConstValue.onlineStatus
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          constraints: BoxConstraints.tightFor(
              width: widget.snap[ModelMsgSend.currentLocationKey]
                          .toString()
                          .length >
                      3
                  ? MediaQuery.of(context).size.width * .5
                  : widget.snap[ModelMsgSend.docURLKey].toString().isNotEmpty
                      ? MediaQuery.of(context).size.width * .5
                      : widget.snap[ModelMsgSend.imageURLKey]
                              .toString()
                              .isNotEmpty
                          ? MediaQuery.of(context).size.width * .65
                          : widget.snap[ModelMsgSend.voiceURLKey]
                                  .toString()
                                  .isNotEmpty
                              ? MediaQuery.of(context).size.width * .7
                              : widget.snap[ModelMsgSend.messageKey]
                                          .toString()
                                          .length <
                                      5
                                  ? MediaQuery.of(context).size.width * .2
                                  : widget.snap[ModelMsgSend.messageKey]
                                              .toString()
                                              .length <
                                          15
                                      ? MediaQuery.of(context).size.width * .4
                                      : MediaQuery.of(context).size.width * .7),
          decoration: BoxDecoration(
              color: widget.snap[ModelMsgSend.isSendByMeKey] ==
                      ConstValue.onlineStatus
                  ? ConstValue.frontColor
                  : Colors.blue,
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 4, left: 5, right: 5, bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.snap[ModelMsgSend.messageKey] != ''
                    ? Text(
                        widget.snap[ModelMsgSend.messageKey],
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      )
                    : widget.snap[ModelMsgSend.voiceURLKey] != ''
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * .7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: IconButton(
                                    onPressed: () async {
                                      if (isPlaying) {
                                        if(mounted) {
                                          setState(() {
                                            player!.pause();
                                            isPlaying = false;
                                          });
                                        }
                                      } else {
                                        player = AudioPlayer(
                                            playerId: widget.snap[
                                                ModelMsgSend.voiceURLKey]);

                                        player!.onPlayerComplete
                                            .listen((event) {
                                              if(mounted) {
                                                setState(() {
                                                  isPlaying = false;
                                                });
                                              }
                                        });
                                        player!.onDurationChanged
                                            .listen((value) {
                                          if (mounted) {
                                            setState(() {
                                              durationAudio = value;
                                            });
                                          }
                                        });

                                        player!.onPositionChanged
                                            .listen((value) {
                                          if (mounted) {
                                            setState(() {
                                              positionAudio = value;
                                            });
                                          }
                                        });

                                        DefaultCacheManager()
                                            .getSingleFile(widget
                                                .snap[ModelMsgSend.voiceURLKey])
                                            .then((value) {
                                          player!.play(
                                              DeviceFileSource(value.path));
                                        });

                                        isPlaying = true;
                                      }
                                    },
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  key: UniqueKey(),
                                  flex: 8,
                                  child: Slider(
                                    thumbColor: ConstValue.backgroundColor,
                                    inactiveColor: Colors.white,
                                    activeColor: ConstValue.backgroundColor,
                                    onChanged: (duration) {},
                                    value:
                                        positionAudio.inMilliseconds.toDouble(),
                                    min: 0,
                                    max:
                                        durationAudio.inMilliseconds.toDouble(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : widget.snap[ModelMsgSend.docURLKey] != ''
                            ? InkWell(
                                onTap: () async {
                                  var file = await DefaultCacheManager()
                                      .getSingleFile(
                                          widget.snap[ModelMsgSend.docURLKey]);

                                  OpenFile.open(file.path);
                                },
                                child:const Image(image: AssetImage('assets/pdf.png'),color: Colors.white,) )
                            : widget.snap[ModelMsgSend.imageURLKey] != ''
                                ? CachedNetworkImage(
                                    imageUrl:
                                        widget.snap[ModelMsgSend.imageURLKey],
                                    height: 250,
                                    alignment: Alignment.center,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                    placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.camera_alt,
                                          size: 100,
                                          color: Colors.grey,
                                        ))
                                : InkWell(
                                    onTap: () {
                                      //Uri  url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${_locationData.latitude},${_locationData.longitude}');
                                      List location = widget.snap[
                                          ModelMsgSend.currentLocationKey];

                                      Uri url = Uri.parse(
                                          "google.navigation:q=${location[0]},${location[1]}&mode=d");
                                      launchUrl(url);
                                    },
                                    child: const Image(
                                      image: AssetImage(
                                          'assets/currentlocation.jpg'),
                                      fit: BoxFit.fill,
                                      height: 100,
                                      width: 200,
                                    ),
                                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.jm().format(
                          DateTime.parse(widget.snap[ModelMsgSend.sendTimeKEy]),
                        ),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      widget.snap[ModelMsgSend.isSendByMeKey] ==
                              ConstValue.onlineStatus
                          ? Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: widget.snap[ModelMsgSend.seenStatusKey] ==
                                      ConstValue.statusSend
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 3.0),
                                      child: Stack(
                                        children: [
                                          Icon(
                                            Icons.check,
                                            color: widget.snap[ModelMsgSend
                                                        .seenStatusKey] ==
                                                    ConstValue.statusSeen
                                                ? Colors.cyanAccent
                                                : Colors.white,
                                            size: 16,
                                          ),
                                          Positioned(
                                            top: 4,
                                            child: Icon(
                                              Icons.check,
                                              color: widget.snap[ModelMsgSend
                                                          .seenStatusKey] ==
                                                      ConstValue.statusSeen
                                                  ? Colors.cyanAccent
                                                  : Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                          : const SizedBox()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
