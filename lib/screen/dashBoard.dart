import 'package:chats_app/model_classes/model_user_info_status.dart';
import 'package:chats_app/screen/chat_screen.dart';
import 'package:chats_app/utils/const_value.dart';
import 'package:chats_app/utils/utils.dart';
import 'package:chats_app/utils/validation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    updateUserStatus(onlineStatus: ConstValue.onlineStatus);
    fetchContact().then((value) {
      fetchUserUID().then((uid) {
        for (int i = 0; i < value.length; i++) {
          if (value[i].phones.isNotEmpty) {
            if (ConstValue.prefs!.get(ConstValue.userNumber) !=
                value[i].phones[0].normalizedNumber) {
              if (uid.contains(value[i].phones[0].normalizedNumber)) {
                fetchPersonalChatUser().then((personalUser) {
                  if (!personalUser
                      .contains(value[i].phones[0].normalizedNumber)) {
                    print(value[i].phones[0].normalizedNumber);

                    var ourStatus = ModelUserInfoStatus(
                        userName: value[i].displayName,
                        onlineStatus: ConstValue.offlineStatus,
                        userToken: '',
                        lastSeen: '',
                        userNumber: value[i].phones[0].normalizedNumber);

                    FirebaseFirestore.instance
                        .collection(ConstValue.userCollection)
                        .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
                        .collection(ConstValue.personalChatCollection)
                        .doc(value[i].phones[0].normalizedNumber)
                        .set(ourStatus.toMap());

                    var otherUserStatus = ModelUserInfoStatus(
                        userName:
                            ConstValue.prefs!.getString(ConstValue.userName)!,
                        onlineStatus: ConstValue.offlineStatus,
                        userToken: '',
                        lastSeen: '',
                        userNumber: ConstValue.prefs!
                            .getString(ConstValue.userNumber)!);

                    FirebaseFirestore.instance
                        .collection(ConstValue.userCollection)
                        .doc(value[i].phones[0].normalizedNumber)
                        .collection(ConstValue.personalChatCollection)
                        .doc(ConstValue.prefs!.getString(ConstValue.userNumber))
                        .set(otherUserStatus.toMap());
                  }
                });
              }
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    updateUserStatus(onlineStatus: ConstValue.offlineStatus);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ConstValue.backgroundColor,
        appBar: AppBar(
          backgroundColor: ConstValue.frontColor,
          title: const Text('ChillChart'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Center(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(ConstValue.userCollection)
                      .doc(ConstValue.prefs!.getString(ConstValue.userNumber)!)
                      .collection(ConstValue.personalChatCollection)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasData) {
                      if(snapshot.data!.docs.length > 0) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection(ConstValue.userCollection)
                                    .doc(snapshot.data!.docs[index]
                                [ModelUserInfoStatus.userNumberKEy])
                                    .collection(
                                    ConstValue.personalChatCollection)
                                    .doc(ConstValue.prefs!
                                    .getString(ConstValue.userNumber)!)
                                    .update({
                                  ModelUserInfoStatus.lastSeenKEy:
                                  DateTime.now().toString(),
                                  ModelUserInfoStatus.onlineStatusKEy:
                                  ConstValue.onlineStatus
                                });

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatScreen(
                                              name: snapshot.data!.docs[index]
                                              [ModelUserInfoStatus.userNameKEy],
                                              number: snapshot.data!
                                                  .docs[index][
                                              ModelUserInfoStatus
                                                  .userNumberKEy]),
                                    ));
                              },
                              child: Card(
                                elevation: ConstValue.btnElevation,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  title: Text(
                                    snapshot.data!.docs[index]
                                    [ModelUserInfoStatus.userNameKEy],
                                    style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: ConstValue.frontColor,
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )),
                                  ),
                                  trailing: Container(
                                    color: ConstValue.frontColor,
                                    width: 80,
                                    alignment: Alignment.center,
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection(ConstValue.userCollection)
                                          .doc(snapshot.data!.docs[index]
                                      [ModelUserInfoStatus.userNumberKEy])
                                          .collection(
                                          ConstValue.personalChatCollection)
                                          .doc(ConstValue.prefs!
                                          .getString(ConstValue.userNumber))
                                          .snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<
                                              DocumentSnapshot<
                                                  Map<String, dynamic>>>
                                          snapshotLastSeen) {
                                        if (snapshotLastSeen.hasData) {
                                          return Text(
                                            snapshotLastSeen.data![
                                            ModelUserInfoStatus
                                                .lastSeenKEy] ==
                                                ''
                                                ? 'New User'
                                                : DateFormat.jm().format(
                                              DateTime.parse(
                                                  snapshotLastSeen.data![
                                                  ModelUserInfoStatus
                                                      .lastSeenKEy]),
                                            ),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }else{
                        return const Center(child :  Text('No one available for chat'));
                      }
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
            ),
          ),
        ));
  }
}
