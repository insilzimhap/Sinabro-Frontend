class ParentQuestion {
  final int id;
  final String questionText;
  final List<ParentOption> options;

  ParentQuestion(
      {required this.id, required this.questionText, required this.options});

  factory ParentQuestion.fromJson(Map<String, dynamic> json) {
    return ParentQuestion(
      id: json['id'],
      questionText: json['questionText'],
      options: (json['options'] as List)
          .map((opt) => ParentOption.fromJson(opt))
          .toList(),
    );
  }
}

class LevelTestOption {
  final int? id;
  final String optionText;
  final String? imageUrl;
  final bool correct;

  LevelTestOption({
    required this.id,
    required this.optionText,
    required this.imageUrl,
    required this.correct,
  });

  factory LevelTestOption.fromJson(Map<String, dynamic> json) {
    return LevelTestOption(
      id: json['id'],
      optionText: json['optionText'],
      imageUrl: json['imageUrl'],
      correct: json['correct'],
    );
  }
}

class LevelTestQuestion {
  final int id;
  final int level;
  final String type;
  final String prompt;
  final String? questionImageUrl;
  final String? audioUrl;
  final List<LevelTestOption> options;

  LevelTestQuestion({
    required this.id,
    required this.level,
    required this.type,
    required this.prompt,
    required this.questionImageUrl,
    required this.audioUrl,
    required this.options,
  });

  factory LevelTestQuestion.fromJson(Map<String, dynamic> json) {
    return LevelTestQuestion(
      id: json['id'],
      level: json['level'],
      type: json['type'],
      prompt: json['prompt'],
      questionImageUrl: json['questionImageUrl'],
      audioUrl: json['audioUrl'],
      options: (json['options'] as List)
          .map((opt) => LevelTestOption.fromJson(opt))
          .toList(),
    );
  }
}

class LevelTestResponse {
  final List<ParentQuestion> parentQuestions;
  final List<LevelTestQuestion> levelTestQuestions;

  LevelTestResponse({
    required this.parentQuestions,
    required this.levelTestQuestions,
  });

  factory LevelTestResponse.fromJson(Map<String, dynamic> json) {
    return LevelTestResponse(
      parentQuestions: (json['parentQuestions'] as List)
          .map((p) => ParentQuestion.fromJson(p))
          .toList(),
      levelTestQuestions: (json['levelTestQuestions'] as List)
          .map((q) => LevelTestQuestion.fromJson(q))
          .toList(),
    );
  }
}

class ParentOption {
  final int id;
  final String optionText;

  ParentOption({required this.id, required this.optionText});

  factory ParentOption.fromJson(Map<String, dynamic> json) {
    return ParentOption(
      id: json['id'],
      optionText: json['optionText'],
    );
  }
}
