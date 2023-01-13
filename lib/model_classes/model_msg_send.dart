


class ModelMsgSend {


  late String _sendTime;
  late String _deliverTime;
  late String _seenTime;

  late String _isRepliedMessage;
  late String _repliedMessage;
  late String _seenStatus;
  late String _isSendByMe;

  late String _message;
  late String _voiceURL;
  late String _imageURL;
  late String _docURL;
  late List _currentLocation;

  static const String sendTimeKEy = 'sendTime';
  static const String deliverTimeKEy = 'deliverTime';
  static const String seenTimeKey = 'seenTime';

  static const String isRepliedMessageKey = 'isRepliedMessage';
  static const String repliedMessageKey = 'repliedMessage';
  static const String seenStatusKey = 'seenStatus';
  static const String isSendByMeKey = 'isSendByMe';

  static const String messageKey = 'message';
  static const String voiceURLKey = 'voiceURL';
  static const String imageURLKey = 'imageURL';
  static const String docURLKey = 'docURL';
  static const String currentLocationKey = 'currentLocation';

  ModelMsgSend({
    required String sendTime,
    required String deliverTime,
    required String seenTime,
    required String isRepliedMessage,
    required String repliedMessage,
    required String seenStatus,
    required String isSendByMe,
    required String message,
    required String voiceURl,
    required List currentLocation,
    required String imageURl,
    required String docURl,
  })  : _sendTime = sendTime,
        _deliverTime = deliverTime,
        _seenTime = seenTime,
        _docURL = docURl,

  _currentLocation = currentLocation,
        _isRepliedMessage = isRepliedMessage,
        _repliedMessage = repliedMessage,
        _seenStatus = seenStatus,
        _voiceURL = voiceURl,
        _message = message,
        _isSendByMe = isSendByMe,
        _imageURL = imageURl;

  Map<String, dynamic> toMap() {
    return {
      sendTimeKEy: sendTime,
      deliverTimeKEy: deliverTime,
      seenTimeKey: seenTime,
      docURLKey: docURL,
      isRepliedMessageKey: isRepliedMessage,
      repliedMessageKey: repliedMessage,
      seenStatusKey: seenStatus,
      isSendByMeKey: isSendByMe,
      currentLocationKey : currentLocation,
      messageKey: message,
      voiceURLKey: voiceURL,
      imageURLKey: imageURL,
    };
  }


  List get currentLocation => _currentLocation;


  set currentLocation(List value) {
    _currentLocation = value;
  }

  String get docURL => _docURL;

  set docURL(String value) {
    _docURL = value;
  }

  String get imageURL => _imageURL;

  set imageURL(String value) {
    _imageURL = value;
  }

  String get voiceURL => _voiceURL;

  set voiceURL(String value) {
    _voiceURL = value;
  }

  String get isSendByMe => _isSendByMe;

  set isSendByMe(String value) {
    _isSendByMe = value;
  }

  String get seenStatus => _seenStatus;

  set seenStatus(String value) {
    _seenStatus = value;
  }

  String get repliedMessage => _repliedMessage;

  set repliedMessage(String value) {
    _repliedMessage = value;
  }

  String get isRepliedMessage => _isRepliedMessage;

  set isRepliedMessage(String value) {
    _isRepliedMessage = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  String get seenTime => _seenTime;

  set seenTime(String value) {
    _seenTime = value;
  }

  String get deliverTime => _deliverTime;

  set deliverTime(String value) {
    _deliverTime = value;
  }

  String get sendTime => _sendTime;

  set sendTime(String value) {
    _sendTime = value;
  }
}
