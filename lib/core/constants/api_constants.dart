import 'app_globals.dart';

class ApiConstants {
  static const String apiKeyLocal = 'http://10.0.2.2:3104/';
  static const String apiKeyServer = 'https://astrolingo.onrender.com/';
  static const String apiKeyAws = 'http://10.0.2.2:3104/';

  static const String apiScanLocal = 'http://10.0.2.2:8000/';
  static const String apiScanServer = 'http://10.0.2.2:8000/';

  static String get baseUrl =>
      AppGlobals.useLocalApi ? apiKeyLocal : apiKeyServer;
  static String get baseScanUrl =>
      AppGlobals.useLocalScanApi ? apiScanLocal : apiScanServer;
}
