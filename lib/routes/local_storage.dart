// filepath: c:\Users\ahmed\OneDrive\Desktop\GIU\flutter code files\Beats\lib\routes\local_storage.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAnalysis {
  final String id;
  final DateTime createdAt;
  final Map<String, dynamic> payload;
  final String? apixabanRecommendation;
  final String? justification;
  final List<String>? comprehensiveAnalysis;
  final String? interpretationSummary;
  final String? aiModel;
  final String? aiRequestId;

  SavedAnalysis({
    required this.id,
    required this.createdAt,
    required this.payload,
    this.apixabanRecommendation,
    this.justification,
    this.comprehensiveAnalysis,
    this.interpretationSummary,
    this.aiModel,
    this.aiRequestId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'payload': payload,
        'apixabanRecommendation': apixabanRecommendation,
        'justification': justification,
        'comprehensiveAnalysis': comprehensiveAnalysis,
        'interpretationSummary': interpretationSummary,
        'aiModel': aiModel,
        'aiRequestId': aiRequestId,
      };

  static SavedAnalysis fromJson(Map<String, dynamic> j) => SavedAnalysis(
        id: j['id'] as String,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
        payload: (j['payload'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        apixabanRecommendation: j['apixabanRecommendation'] as String?,
        justification: j['justification'] as String?,
        comprehensiveAnalysis: (j['comprehensiveAnalysis'] as List?)?.whereType<String>().toList(),
        interpretationSummary: j['interpretationSummary'] as String?,
        aiModel: j['aiModel'] as String?,
        aiRequestId: j['aiRequestId'] as String?,
      );
}

class LocalStorage {
  LocalStorage._();
  static final LocalStorage instance = LocalStorage._();

  static const String _key = 'saved_analyses';

  // Notifier to update UI when items change
  final ValueNotifier<List<SavedAnalysis>> analyses = ValueNotifier<List<SavedAnalysis>>([]);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      analyses.value = [];
      return;
    }
    try {
      final list = json.decode(raw);
      if (list is List) {
        analyses.value = list
            .whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .map(SavedAnalysis.fromJson)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        analyses.value = [];
      }
    } catch (_) {
      analyses.value = [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = analyses.value.map((e) => e.toJson()).toList(growable: false);
    await prefs.setString(_key, json.encode(list));
  }

  Future<void> add(SavedAnalysis item) async {
    final current = List<SavedAnalysis>.from(analyses.value);
    current.insert(0, item);
    analyses.value = current;
    await _persist();
  }

  Future<void> removeById(String id) async {
    analyses.value = analyses.value.where((e) => e.id != id).toList();
    await _persist();
  }

  // Convenience for creating an item from analysis data
  Future<void> saveFromPayload({
    required Map<String, dynamic> payload,
    String? apixabanRecommendation,
    String? justification,
    List<String>? comprehensiveAnalysis,
    String? interpretationSummary,
    String? aiModel,
    String? aiRequestId,
  }) async {
    final item = SavedAnalysis(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      payload: payload,
      apixabanRecommendation: apixabanRecommendation,
      justification: justification,
      comprehensiveAnalysis: comprehensiveAnalysis,
      interpretationSummary: interpretationSummary,
      aiModel: aiModel,
      aiRequestId: aiRequestId,
    );
    await add(item);
  }
}
