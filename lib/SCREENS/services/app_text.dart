import 'package:flutter/widgets.dart';
import '../main.dart';

class AppText {
  static String t(BuildContext context, String en, String hi, String bn) {
    final lang = JanArogyaApp.of(context)?.currentLanguageCode ?? 'en';
    if (lang == 'hi') return hi;
    if (lang == 'bn') return bn;
    return en;
  }
}
