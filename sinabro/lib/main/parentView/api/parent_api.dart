import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinabro/config.dart';

class ParentApi {
  // 부모 프로필 조회
  static Future<String> fetchParentName(String userId) async {
    final uri = Uri.parse('$baseUrl/api/users/profile?userId=$userId');
    final res = await http.get(uri);

    // 디버그 로그
    // ignore: avoid_print
    print('[GET /api/users/profile] ${res.statusCode} ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['userName'] as String?) ?? '';
    }
    throw Exception('부모 이름 로드 실패: ${res.statusCode} ${res.body}');
  }

  // 자녀 목록 조회
  static Future<List<ChildSummary>> fetchChildren(String userId) async {
    final uri = Uri.parse('$baseUrl/api/children').replace(
      queryParameters: {
        // ⚠️ 백엔드 요구사항 확인: userId / parentId / userSeq 중 무엇인지
        'userId': userId,
      },
    );

    final res = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    // 디버그 로그
    // ignore: avoid_print
    print('[GET /api/children] ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('자녀 목록 로드 실패: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);

    // 1) 배열 그대로 오는 경우
    if (body is List) {
      return body.map((e) => ChildSummary.fromJsonFlexible(e)).toList();
    }

    // 2) { "data": [ ... ] } 형태
    if (body is Map && body['data'] is List) {
      final list = body['data'] as List;
      return list.map((e) => ChildSummary.fromJsonFlexible(e)).toList();
    }

    // 3) { "items": [ ... ] } 형태
    if (body is Map && body['items'] is List) {
      final list = body['items'] as List;
      return list.map((e) => ChildSummary.fromJsonFlexible(e)).toList();
    }

    throw Exception('알 수 없는 자녀 응답 구조: ${res.body}');
  }
}

class ChildSummary {
  final String childId;
  final String childName;
  final String? childNickname;
  final int? childAge;

  ChildSummary({
    required this.childId,
    required this.childName,
    this.childNickname,
    this.childAge,
  });

  // 원래 fromJson (키 고정)
  factory ChildSummary.fromJson(Map<String, dynamic> json) {
    return ChildSummary(
      childId: json['childId'] as String,
      childName: json['childName'] as String,
      childNickname: json['childNickname'] as String?,
      childAge:
          (json['childAge'] == null) ? null : (json['childAge'] as num).toInt(),
    );
  }

  // 키 이름·타입이 달라도 파싱되는 유연 버전
  factory ChildSummary.fromJsonFlexible(dynamic raw) {
    final j = (raw as Map).cast<String, dynamic>();

    final id = j['childId'] ?? j['id'] ?? j['child_id'] ?? '';
    final name = j['childName'] ?? j['name'] ?? j['child_name'] ?? '';
    final nick = j['childNickname'] ?? j['nickname'] ?? j['nick'] ?? j['alias'];
    final ageRaw = j['childAge'] ?? j['age'];

    int? age;
    if (ageRaw != null) {
      if (ageRaw is num) {
        age = ageRaw.toInt();
      } else if (ageRaw is String) {
        age = int.tryParse(ageRaw);
      }
    }

    return ChildSummary(
      childId: id.toString(),
      childName: name.toString(),
      childNickname: nick?.toString(),
      childAge: age,
    );
  }

  String get displayName =>
      (childNickname != null && childNickname!.trim().isNotEmpty)
          ? childNickname!
          : childName;

  String get displayAge => (childAge == null) ? '' : '${childAge}세';
}
