@JS()
library env;

import 'package:js/js.dart';

@JS('window.env')
external EnvConfig get env;

@JS()
@anonymous
class EnvConfig {
  external String get API_URL;
}
