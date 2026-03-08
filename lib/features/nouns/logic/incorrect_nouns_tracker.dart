import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/german_noun.dart';

class IncorrectNounsTracker {
  static const String sessionKey = 'session_incorrect_words';
  static const String allTimeKey = 'all_time_incorrect_words';

  static Future<void> addIncorrectNoun(GermanNoun noun) async {
    final prefs = await SharedPreferences.getInstance();

    final sessionJson = prefs.getString(sessionKey) ?? '[]';
    final sessionList = List<Map<String, dynamic>>.from(
      jsonDecode(sessionJson),
    );

    if (!sessionList.any((n) => n['noun'] == noun.noun)) {
      sessionList.add(noun.toJson());
    }

    await prefs.setString(sessionKey, jsonEncode(sessionList));
  }

  static Future<List<GermanNoun>> getSessionIncorrectNouns() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(sessionKey) ?? '[]';
    final list = List<Map<String, dynamic>>.from(jsonDecode(json));
    return list.map((item) => GermanNoun.fromJson(item)).toList();
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionKey);
  }
}
