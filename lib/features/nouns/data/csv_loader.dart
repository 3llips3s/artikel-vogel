import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/german_noun.dart';

class CsvLoader {
  static const String cacheKey = 'german_words_cache';

  static Future<List<GermanNoun>> loadNouns() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      return _parseNounsFromJson(cachedJson);
    }

    final csvData = await rootBundle.loadString('assets/data/german_nouns.csv');
    final List<List<dynamic>> rows = const CsvToListConverter().convert(
      csvData,
      shouldParseNumbers: false,
    );

    final nouns = <GermanNoun>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length >= 4) {
        nouns.add(
          GermanNoun(
            article: row[0].toString().trim(),
            noun: row[1].toString().trim(),
            plural: row[2].toString().trim(),
            english: row[3].toString().trim(),
          ),
        );
      }
    }

    await prefs.setString(
      cacheKey,
      jsonEncode(nouns.map((noun) => noun.toJson()).toList()),
    );

    return nouns;
  }

  static List<GermanNoun> _parseNounsFromJson(String json) {
    final List<dynamic> decoded = jsonDecode(json);
    return decoded
        .map((item) => GermanNoun.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
