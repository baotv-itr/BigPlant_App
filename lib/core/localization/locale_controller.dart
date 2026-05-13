import 'package:flutter/material.dart';

import '../../features/auth/data/storage_service.dart';
import '../constants/app_globals.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  Future<void> init() async {
    final code = await StorageService.getLanguageCode();
    if (code != null && (code == 'vi' || code == 'en')) {
      _locale = Locale(code);
      AppGlobals.currentLanguageCode = code;
    }
    notifyListeners();
  }

  Future<void> toggle() async {
    final newCode = _locale.languageCode == 'vi' ? 'en' : 'vi';
    _locale = Locale(newCode);
    AppGlobals.currentLanguageCode = newCode;
    await StorageService.setLanguageCode(newCode);
    notifyListeners();
  }
}

class LocaleScope extends InheritedWidget {
  const LocaleScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final LocaleController controller;

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(covariant LocaleScope oldWidget) {
    return oldWidget.controller != controller;
  }
}
