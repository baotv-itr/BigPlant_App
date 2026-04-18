import 'app_globals.dart';

class ApiConstants {
  static const String apiKeyLocal = 'http://127.0.0.1:3104/';
  static const String apiKeyServer = 'https://astrolingo.onrender.com/';
  static const String apiKeyAws = 'http://10.0.2.2:3104/';

  static String get baseUrl =>
      AppGlobals.useLocalApi ? apiKeyLocal : apiKeyServer;
}
