import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/models/faq_entry.dart';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String text;
  final bool isUser;
  final DateTime timestamp;
}

class ChatbotController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final entries = <FaqEntry>[].obs;
  final loading = true.obs;
  final fallbackAnswer = ''.obs;
  final fallbackAnswerSw = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaq();
  }

  Future<void> _loadFaq() async {
    try {
      final raw = await rootBundle.loadString('assets/faq.json');
      final data = json.decode(raw) as Map<String, dynamic>;
      final list = (data['intents'] as List? ?? [])
          .map((e) => FaqEntry.fromMap(e as Map<String, dynamic>))
          .toList();
      entries.assignAll(list);
      final fallback = (data['fallback'] as Map?) ?? {};
      fallbackAnswer.value = (fallback['answer'] ?? '').toString();
      fallbackAnswerSw.value = (fallback['answer_sw'] ?? '').toString();
    } catch (_) {
      fallbackAnswer.value = "I do not have that information yet.";
      fallbackAnswerSw.value = "Sina taarifa hiyo kwa sasa.";
    } finally {
      loading.value = false;
      if (messages.isEmpty) {
        messages.add(ChatMessage(
          text: _isSw ? "Habari, naweza kukusaidia nini?" : "Hello, how can I help you today?",
          isUser: false,
        ));
      }
    }
  }

  void sendMessage(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    messages.add(ChatMessage(text: cleaned, isUser: true));

    final response = _matchAnswer(cleaned);
    messages.add(ChatMessage(text: response, isUser: false));
  }

  String _matchAnswer(String input) {
    if (entries.isEmpty) {
      return _fallbackText();
    }

    final needle = input.toLowerCase();
    FaqEntry? best;
    var bestScore = 0;

    for (final entry in entries) {
      final score = _scoreEntry(entry, needle);
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }

    if (best == null || bestScore == 0) {
      return _fallbackText();
    }

    final answer = _isSw ? (best.answerSw ?? best.answer) : best.answer;
    return answer.isEmpty ? _fallbackText() : answer;
  }

  int _scoreEntry(FaqEntry entry, String needle) {
    int score = 0;
    final q = entry.question.toLowerCase();
    if (needle.contains(q)) {
      score += 5;
    }

    final keywords = _isSw ? entry.keywordsSw : entry.keywords;
    for (final keyword in keywords) {
      if (needle.contains(keyword.toLowerCase())) {
        score += 2;
      }
    }
    return score;
  }

  bool get _isSw => Get.locale?.languageCode == 'sw';

  String _fallbackText() {
    if (_isSw) {
      return fallbackAnswerSw.value.isNotEmpty
          ? fallbackAnswerSw.value
          : "Sina taarifa hiyo kwa sasa.";
    }
    return fallbackAnswer.value.isNotEmpty
        ? fallbackAnswer.value
        : "I do not have that information yet.";
  }
}
