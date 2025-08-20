import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinabro/config.dart';

class ParentApi {
  // GET $baseUrl/api/users/profile?userId=...
  static Future<String> fetchParentName(String userId) async {
    final uri = Uri.parse('$baseUrl/api/users/profile?userId=$userId');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['userName'] as String?) ?? '';
    }
    throw Exception('부모 이름 로드 실패: ${res.statusCode}');
  }

  // GET $baseUrl/api/children?userId=...
  static Future<List<ChildSummary>> fetchChildren(String userId) async {
    final uri = Uri.parse('$baseUrl/api/children?userId=$userId');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((e) => ChildSummary.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('자녀 목록 로드 실패: ${res.statusCode}');
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
    required this.childNickname,
    required this.childAge,
  });

  factory ChildSummary.fromJson(Map<String, dynamic> json) {
    return ChildSummary(
      childId: json['childId'] as String,
      childName: json['childName'] as String,
      childNickname: json['childNickname'] as String?,
      childAge: (json['childAge'] == null) ? null : (json['childAge'] as num).toInt(),
    );
  }

  String get displayName =>
      (childNickname != null && childNickname!.trim().isNotEmpty)
          ? childNickname!
          : childName;

  String get displayAge => (childAge == null) ? '' : '${childAge}세';
}
