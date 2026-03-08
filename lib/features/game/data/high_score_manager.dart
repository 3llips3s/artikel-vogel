import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

// spell: words prefs
class HighScoreManager {
  static const String _highScoreKey = 'artikel_vogel_high_score';

  static Future<int> getHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_highScoreKey) ?? 0;
    } catch (e) {
      developer.log('Error getting high score: $e');
      return 0;
    }
  }

  static Future<bool> updateHighScore(int score) async {
    try {
      final currentHighScore = await getHighScore();

      if (score > currentHighScore) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_highScoreKey, score);
        return true;
      }

      return false;
    } catch (e) {
      developer.log('error updating high score: $e');
      return false;
    }
  }

  static Future<bool> isNewHighSCore(int score) async {
    final currentHighScore = await getHighScore();
    return score > currentHighScore;
  }

  static Future<void> resetHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_highScoreKey);
    } catch (e) {
      developer.log('error resetting high score: $e');
    }
  }
}
