import 'dart:async';
import 'child_state.dart';
import 'fruit_state.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinabro/config.dart';

/// 🎯 더미 게임 API (childId + fruitId 자동 포함)
/// 🎯 게임용 API (듣기 / 쓰기 공용)
/// JWT 없이 childId + fruitId 로 동작
class ChildGameApi {


//------------------ 쓰기 게임 API ------------------------//
  static const _base = '$baseUrl/api/app/games/writing';

  /// 🎬 1. 쓰기 게임 시작
  /// - childId + fruitId로 입장 검증
  /// - OK 시 resultId 반환
  static Future<String?> startWritingGame() async {
    final childId = ChildState.instance.childId;
    final fruitId = FruitState.instance.fruitId;

    if (childId == null || fruitId == null) {
      print('[ChildGameApi][start] ❌ childId 또는 fruitId 누락');
      return null;
    }

    final uri = Uri.parse('$_base/start');
    final body = jsonEncode({
      'childId': childId,
      'fruitId': fruitId,
    });

    print('[ChildGameApi][start] 요청 → $body');

    try {
      final resp = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        print('[ChildGameApi][start] ✅ 성공: $data');
        return data['resultId'];
      } else if (resp.statusCode == 403) {
        print('[ChildGameApi][start] 🚫 잠금 상태 열매: 403 Forbidden');
      } else if (resp.statusCode == 404) {
        print('[ChildGameApi][start] ❌ 자녀/열매 없음');
      } else {
        print('[ChildGameApi][start] ⚠️ 오류: ${resp.statusCode}');
      }
    } catch (e) {
      print('[ChildGameApi][start] 예외 발생: $e');
    }
    return null;
  }

  /// ✍️ 2. 선택 기록 저장
  /// - 채점 완료 후 호출 (필기 인식 SDK 결과 전달)
  /// - 성공 시 204 반환
  static Future<bool> recordWritingChoice({
    required String resultId,
    required String questionId,
    required bool isCorrect,
    String? childWrittenText,
  }) async {
    final uri = Uri.parse('$_base/choice');
    final body = jsonEncode({
      'resultId': resultId,
      'questionId': questionId,
      'isCorrect': isCorrect,
      'childWrittenText': childWrittenText,
    });

    print('[ChildGameApi][choice] 요청 → $body');

    try {
      final resp = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 204) {
        print('[ChildGameApi][choice] ✅ 선택 기록 성공');
        return true;
      } else if (resp.statusCode == 409) {
        print('[ChildGameApi][choice] ⚠️ 중복 questionId (409)');
      } else if (resp.statusCode == 404) {
        print('[ChildGameApi][choice] ❌ resultId/questionId 없음');
      } else {
        print('[ChildGameApi][choice] ⚠️ 상태코드=${resp.statusCode}');
      }
    } catch (e) {
      print('[ChildGameApi][choice] 예외: $e');
    }
    return false;
  }

  /// ✅ 3. 게임 완료
  /// - 모든 문제를 푼 뒤 호출
  /// - 서버가 점수 계산 + 결과 저장 + 다음 열매 활성화 수행
  static Future<Map<String, dynamic>?> completeWritingGame({
    required String resultId,
    required int timeSpentSecs,
  }) async {
    final childId = ChildState.instance.childId;
    final fruitId = FruitState.instance.fruitId;

    if (childId == null || fruitId == null) {
      print('[ChildGameApi][complete] ❌ childId 또는 fruitId 누락');
      return null;
    }

    final uri = Uri.parse('$_base/complete');
    final body = jsonEncode({
      'childId': childId,
      'fruitId': fruitId,
      'resultId': resultId,
      'timeSpentSecs': timeSpentSecs,
    });

    print('[ChildGameApi][complete] 요청 → $body');

    try {
      final resp = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        print('[ChildGameApi][complete] ✅ 완료 성공: $data');
        return data;
      } else if (resp.statusCode == 404) {
        print('[ChildGameApi][complete] ❌ 자녀/결과/열매 없음');
      } else if (resp.statusCode == 400) {
        print('[ChildGameApi][complete] ⚠️ 선택 기록 누락 (400)');
      } else {
        print('[ChildGameApi][complete] ⚠️ 상태코드=${resp.statusCode}');
      }
    } catch (e) {
      print('[ChildGameApi][complete] 예외: $e');
    }
    return null;
  }

  /// 🌳 4. 나무(열매 진행도) 조회
  /// - 특정 단계(stageId) 기준으로 자녀 열매 활성 여부 + 점수 불러오기
  static Future<List<Map<String, dynamic>>> fetchWritingTree(
      String stageId) async {
    final childId = ChildState.instance.childId;
    if (childId == null) {
      print('[ChildGameApi][tree] ❌ childId 없음');
      return [];
    }

    final uri = Uri.parse('$_base/tree')
        .replace(queryParameters: {'stageId': stageId, 'childId': childId});
    print('[ChildGameApi][tree] 요청 → $uri');

    try {
      final resp = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        print('[ChildGameApi][tree] ✅ 조회 성공 (${data.length}개)');
        return (data as List).cast<Map<String, dynamic>>();
      } else {
        print('[ChildGameApi][tree] ⚠️ 조회 실패: ${resp.statusCode}');
      }
    } catch (e) {
      print('[ChildGameApi][tree] 예외: $e');
    }

    return [];
  }

}
