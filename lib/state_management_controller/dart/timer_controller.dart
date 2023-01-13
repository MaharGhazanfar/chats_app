import 'package:get/get.dart';

class TimerController extends GetxController {
  var countDownTimer = 60.obs;
  var _verificationCode = ''.obs;

  increment() => countDownTimer--;

  get verificationCode => _verificationCode;

  set verificationCode(value) {
    _verificationCode = value;
  }
}
