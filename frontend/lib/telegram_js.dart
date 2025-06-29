@JS('Telegram.WebApp')
library telegram_webapp;

import 'package:js/js.dart';

@JS()
external void ready();

@JS()
external String get version;
@JS()
external String get initData; 
@JS()
external InitData get initDataUnsafe;

@JS()
external void close();

@JS()
external void expand();

@JS()
external void showAlert(String message);

// This is the wrapper object
@JS()
class InitData {
  external WebAppUser? get user;
}

// The actual user object
@JS()
class WebAppUser {
  external int get id;
  external String get first_name;
  external String get last_name;
  external String get username;
  external String get language_code;
  external String get photo_url;
}
