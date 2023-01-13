class ModelUserInfoStatus {
  late String _userName;
  late String _userNumber;
  late String _lastSeen;
  late String _userToken;
  late String _onlineStatus;

  static const String userNameKEy = 'userName';
  static const String userNumberKEy = 'userNumber';
  static const String lastSeenKEy = 'lastSeen';
  static const String onlineStatusKEy = 'onlineStatus';
  static const String userTokenKey = 'userToken';

  ModelUserInfoStatus({
    required String userName,
    required String userNumber,
    required String userToken,
    required String lastSeen,
    required String onlineStatus,
  }) : _userName = userName,
  _userNumber = userNumber,
  _userToken = userToken,
  _lastSeen = lastSeen,
  _onlineStatus = onlineStatus;

  Map<String ,String> toMap(){
    return {
      userNameKEy : userName,
      userNumberKEy : userNumber,
      userTokenKey : userToken,
      onlineStatusKEy : onlineStatus,
      lastSeenKEy : lastSeen
    };
  }


  String get userToken => _userToken;

  set userToken(String value) {
    _userToken = value;
  }

  String get onlineStatus => _onlineStatus;

  set onlineStatus(String value) {
    _onlineStatus = value;
  }

  String get lastSeen => _lastSeen;

  set lastSeen(String value) {
    _lastSeen = value;
  }

  String get userNumber => _userNumber;

  set userNumber(String value) {
    _userNumber = value;
  }

  String get userName => _userName;

  set userName(String value) {
    _userName = value;
  }
}