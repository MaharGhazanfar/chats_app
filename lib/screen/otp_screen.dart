import 'dart:async';
import 'package:chats_app/utils/const_value.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rive/rive.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../model_classes/model_user_info_status.dart';
import '../state_management_controller/dart/timer_controller.dart';
import '../utils/validation.dart';

class OTPScreen extends StatefulWidget {


  const OTPScreen({Key? key, }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController codeController = TextEditingController();

  final TimerController timerController = Get.put(TimerController());
  final globalKey = GlobalKey<FormState>();

  final RoundedLoadingButtonController roundedLoadingButtonController =
      RoundedLoadingButtonController();

  timer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerController.countDownTimer == 0.obs) {
        timer.cancel();
      } else {
        timerController.increment();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    timerController.countDownTimer.value = 60;
    timer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ConstValue.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: globalKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * .45,
                      child: const RiveAnimation.asset(
                        'assets/login.riv',
                        animations: ['Appearing'],
                      )),


                  ///          textField for code .........................................................

                  Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Card(
                        elevation: ConstValue.btnElevation,
                        color: ConstValue.frontColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Obx(
                            () => Column(
                              children: [
                                PinCodeTextField(
                                  length: 6,
                                  obscureText: false,
                                  keyboardType: TextInputType.number,
                                  animationType: AnimationType.scale,
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(8),
                                    fieldHeight: 50,
                                    fieldWidth: 40,
                                    inactiveColor: Colors.tealAccent,
                                    activeFillColor: ConstValue.textFillColor,
                                  ),
                                  animationDuration:
                                      const Duration(milliseconds: 300),
                                  controller: codeController,
                                  onChanged: (value) {},
                                  appContext: context,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: RoundedLoadingButton(
                                      controller:
                                          roundedLoadingButtonController,
                                      color: Colors.indigoAccent,
                                      elevation: ConstValue.btnElevation,
                                      onPressed: () async {
                                        if (globalKey.currentState!
                                            .validate()) {
                                          try {
                                            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                                                verificationId: timerController.verificationCode.toString(), smsCode: codeController.text.toString());

                                            await FirebaseAuth.instance
                                                .signInWithCredential(credential)
                                                .then((value) {
                                              FirebaseMessaging messaging = FirebaseMessaging.instance;
                                              messaging.getToken().then((token) {
                                                print('........token    $token');
                                                var userInfoStatus = ModelUserInfoStatus(
                                                    userToken: token!,
                                                    userName: ConstValue.prefs!.getString(ConstValue.userName)!,
                                                    userNumber:  ConstValue.prefs!.getString(ConstValue.userNumber)!,
                                                    lastSeen: DateTime.now().toString(),
                                                    onlineStatus: ConstValue.onlineStatus);

                                                FirebaseFirestore.instance
                                                    .collection(ConstValue.userCollection)
                                                    .doc( ConstValue.prefs!.getString(ConstValue.userNumber)!)
                                                    .set(userInfoStatus.toMap());
                                              });
                                            });
                                            () {
                                              Navigator.pop(context);
                                            }();
                                          } catch (e) {
                                            print('hello error......');

                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  AlertDialog(content: const Text('Invalid OTP'), actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text('ok'))
                                                  ]),
                                            );
                                          }
                                          roundedLoadingButtonController.reset();

                                        }
                                      },
                                      child: const Text('Verify OTP'),),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Center(
                                      child: Text(
                                    'Do not receive the code?',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                                timerController.countDownTimer.value != 0
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: Center(
                                            child: Text(
                                          'Time out : ${timerController.countDownTimer}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        )),
                                      )
                                    : Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: CupertinoButton(
                                          color: Colors.indigo,
                                          onPressed: () async {
                                            timerController.countDownTimer.value = 60;
                                            timer();
                                            await phoneVerification(
                                              statusForReSend: 'Yes',
                                            context: context);
                                          },
                                          child: const Text(
                                            'Resend',
                                            style: TextStyle(color: Colors.white),
                                          )),
                                    )
                              ],
                            ),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
