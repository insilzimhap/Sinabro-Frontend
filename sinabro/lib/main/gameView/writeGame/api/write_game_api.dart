// lib/main/gameView/writeGame/api/write_game_api.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// ✏️ 쓰기 게임 API
/// - 페이지들은 이 파일만 호출하면 됨.
/// - _USE_DUMMY 를 false 로 바꾸면 실제 백엔드로 전송.
class WriteGameApi {
  static const String _BASE = 'http://localhost:8090/api/write-game';
  static const bool _USE_DUMMY = true; // ▶︎ 실서버 붙일 때 false

  /// ✅ 게임 시작: resultId 반환
  static Future<String> start({
    required String childId,
    required String stageCode,
  }) async {
    if (_USE_DUMMY) {
      await Future.delayed(const Duration(milliseconds: 200));
      return 'dummy_${stageCode}_${DateTime.now().millisecondsSinceEpoch}';
    }

    final res = await http.post(
      Uri.parse('$_BASE/start'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'childId': childId, 'stageCode': stageCode}),
    );

    if (res.statusCode != 200) {
      throw Exception('WriteGameApi.start failed: ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    return (data['resultId'] as String?) ??
        (throw Exception('WriteGameApi.start: resultId missing'));
  }

  /// ✅ 문제별 선택(쓰기 결과) 전송
  static Future<void> sendChoice({
    required String resultId,
    required String questionId,
    required String childWrittenText,
    required bool isCorrect,
  }) async {
    if (_USE_DUMMY) {
      // 로컬 테스트 로그
      // ignore: avoid_print
      print(
        '[WriteGameApi.sendChoice] result=$resultId q=$questionId ok=$isCorrect text="$childWrittenText"',
      );
      await Future.delayed(const Duration(milliseconds: 120));
      return;
    }

    final res = await http.post(
      Uri.parse('$_BASE/choice'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'resultId': resultId,
        'questionId': questionId,
        'childWrittenText': childWrittenText,
        'isCorrect': isCorrect,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('WriteGameApi.sendChoice failed: ${res.statusCode}');
    }
  }

  /// ✅ 게임 완료: 채점 결과(success) 반환
  static Future<CompleteResponse> complete({
    required String resultId,
    int? totalQuestions,
    int? timeSpentSecs,
  }) async {
    if (_USE_DUMMY) {
      await Future.delayed(const Duration(milliseconds: 200));
      final ok = DateTime.now().millisecond % 2 == 0; // 랜덤 성공
      return CompleteResponse(success: ok);
    }

    final res = await http.post(
      Uri.parse('$_BASE/complete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'resultId': resultId,
        'totalQuestions': totalQuestions ?? 4,
        'timeSpentSecs': timeSpentSecs ?? 0,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('WriteGameApi.complete failed: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    // 백엔드가 success만 주든, score/threshold를 주든 대비
    final bool success =
        (data['success'] == true) ||
        ((data['score'] is num) &&
            (data['totalQuestions'] is num) &&
            (data['score'] >= (data['totalQuestions'] / 2 + 1)));
    return CompleteResponse(success: success);
  }
}

/// ✅ 완료 응답 모델
class CompleteResponse {
  final bool success;
  const CompleteResponse({required this.success});
}
