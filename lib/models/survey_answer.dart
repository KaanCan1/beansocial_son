class SurveyAnswer {
  final String userId;
  final String question;
  final String answer;
  final DateTime createdAt;

  SurveyAnswer({
    required this.userId,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(
      userId: json['user_id'],
      question: json['question'],
      answer: json['answer'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'question': question,
      'answer': answer,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 