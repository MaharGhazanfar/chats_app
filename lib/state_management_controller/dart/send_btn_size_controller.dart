import 'package:get/get.dart';

class SendBtnSizeController extends GetxController {
  var voiceButtonHeight = 50.obs;
  var voiceButtonWidth = 50.obs;
  var textFieldValue = ''.obs;

  void changeInSize({required String status}) {
    if (status == 'forward') {
      voiceButtonWidth.value = 70;
      voiceButtonHeight.value = 70;
    } else {
      voiceButtonWidth.value = 50;
      voiceButtonHeight.value = 50;
    }
  }
}
