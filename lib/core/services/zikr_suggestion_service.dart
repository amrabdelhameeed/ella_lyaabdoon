import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ZikrSuggestionService {
  ZikrSuggestionService._();

  /// Submit a zikr suggestion to Firestore
  static Future<void> submitSuggestion({
    required String title,
    required String description,
    required String source,
    bool isWithCounter = false,
    String zikrLevel = 'easy',
  }) async {
    try {
      await FirebaseFirestore.instance.collection('suggestions').add({
        'title': title,
        'description': description,
        'source': source,
        'isWithCounter': isWithCounter,
        'zikrLevel': zikrLevel,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Zikr suggestion submitted successfully');
    } catch (e) {
      debugPrint('❌ Failed to submit suggestion: $e');
      rethrow;
    }
  }
}
