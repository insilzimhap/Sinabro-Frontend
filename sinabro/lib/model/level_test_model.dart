// lib/model/level_test_model.dart

// // 이 파일은 레벨테스트 API 응답 모델 정의 파일
// // 서버 DTO(JSON) 키와 타입, 부모 문항 정렬용 questionOrder 필드를 포함

class ParentQuestion {
  final int id;
  final int questionOrder; // 🔥 부모 문항 순서
  final String questionText;
  final List<ParentOption> options;

  ParentQuestion({
    required this.id,
    required this.questionOrder,
    required this.questionText,
    required this.options,
  });

  factory ParentQuestion.fromJson(Map<String, dynamic> json) {
    return ParentQuestion(
      id: json['id'] as int,
      questionOrder: json['questionOrder'] as int, // 🔥 반드시 포함
      questionText: json['questionText'] as String,
      options: (json['options'] as List)
          .map((opt) => ParentOption.fromJson(opt as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ParentOption {
  final int id;
  final String optionText;

  ParentOption({
    required this.id,
    required this.optionText,
  });

  factory ParentOption.fromJson(Map<String, dynamic> json) {
    return ParentOption(
      id: json['id'] as int,
      optionText: json['optionText'] as String,
    );
  }
}

class LevelTestOption {
  final int? id;            // 서버에서 null 가능성 있음 → nullable
  final String optionText;  // 텍스트가 없을 수도 있지만 서버에선 항상 옴(빈문자 가능)
  final String? imageUrl;   // 이미지 없는 옵션 가능 → nullable
  final bool correct;       // 서버 판정용 값(클라 전송시 무시)

  LevelTestOption({
    required this.id,
    required this.optionText,
    required this.imageUrl,
    required this.correct,
  });

  factory LevelTestOption.fromJson(Map<String, dynamic> json) {
    return LevelTestOption(
      id: json['id'] == null ? null : json['id'] as int,
      optionText: json['optionText'] as String,
      imageUrl: json['imageUrl'] as String?,
      correct: json['correct'] as bool,
    );
  }
}

class LevelTestQuestion {
  final int id;
  final int level;                // 1/2/3
  final String type;              // 예: 듣고 고르기 / 이름 고르기 등
  final String prompt;
  final String? questionImageUrl; // 서버 상대경로('/img/...') → 클라에서 $baseUrl 붙여 사용
  final String? audioUrl;         // 서버 상대경로('/audio/...') → 클라에서 $baseUrl 붙여 사용
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
      id: json['id'] as int,
      level: json['level'] as int,
      type: json['type'] as String,
      prompt: json['prompt'] as String,
      questionImageUrl: json['questionImageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      options: (json['options'] as List)
          .map((opt) => LevelTestOption.fromJson(opt as Map<String, dynamic>))
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
          .map((p) => ParentQuestion.fromJson(p as Map<String, dynamic>))
          .toList(),
      levelTestQuestions: (json['levelTestQuestions'] as List)
          .map((q) => LevelTestQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
