class FaqEntry {
  FaqEntry({
    required this.question,
    required this.answer,
    required this.keywords,
    required this.questionSw,
    required this.answerSw,
    required this.keywordsSw,
  });

  final String question;
  final String answer;
  final List<String> keywords;
  final String? questionSw;
  final String? answerSw;
  final List<String> keywordsSw;

  factory FaqEntry.fromMap(Map<String, dynamic> map) {
    return FaqEntry(
      question: (map['question'] ?? '').toString(),
      answer: (map['answer'] ?? '').toString(),
      keywords: _stringList(map['keywords']),
      questionSw: map['question_sw']?.toString(),
      answerSw: map['answer_sw']?.toString(),
      keywordsSw: _stringList(map['keywords_sw']),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
