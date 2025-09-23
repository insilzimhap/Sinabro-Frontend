/**
 * @file lib/main/parentView/api/parent_api.dart
 * 역할: 부모 관련 API 래퍼. (JWT는 AuthClient가 자동 부착)
 * 서버가 JWT 주체에서 userId를 읽으므로, 더 이상 쿼리스트링 userId를 보내지 않음.
 * @채영
 */
///

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinabro/config.dart';
import 'package:sinabro/common/auth_client.dart';   


final _client = AuthClient.instance;


class ParentApi {
  // 부모 프로필 조회
  static Future<String> fetchParentName(String userId) async {
    final uri = Uri.parse('$baseUrl/api/users/profile'); // ❌ userId 쿼리 제거
    final res = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    // ignore: avoid_print
    print('[ParentApi] 부모 프로필 요청: GET /api/users/profile → ${res.statusCode}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['userName'] as String?) ?? '';
    }
    if (res.statusCode == 401) {
      throw Exception('부모 이름 로드 실패(인증 오류 401): 토큰이 없거나 만료되었습니다.');
    }
    throw Exception('부모 이름 로드 실패: ${res.statusCode} ${res.body}');
  }

  // 부모 기준 자녀 목록 조회
  static Future<List<ChildSummary>> fetchChildren(String userId) async {
    final uri = Uri.parse('$baseUrl/api/children'); // ❌ userId 쿼리 제거
    final res = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    // ignore: avoid_print
    print('[ParentApi] 자녀 목록 요청: GET /api/children → ${res.statusCode}');

    if (res.statusCode != 200) {
      if (res.statusCode == 401) {
        throw Exception('자녀 목록 로드 실패(인증 오류 401): 토큰이 없거나 만료되었습니다.');
      }
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


  // 마이페이지 프리필: GET /api/app/mypage/parent/{userId}
  static Future<ParentProfile> fetchParentProfile(String userId) async {
    final uri = Uri.parse('$baseUrl/api/app/mypage/parent/$userId');
    final res = await _client.get(uri, headers: const {'Accept': 'application/json'});

    // ignore: avoid_print
    print('[GET /api/app/mypage/parent/$userId] ${res.statusCode}');

    if (res.statusCode == 200) {
      return ParentProfile.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 401) {
      throw Exception('프로필 조회 실패(401): 로그인 토큰을 확인해주세요.');
    }
    throw Exception('프로필 조회 실패: ${res.statusCode} ${res.body}');
  }

  // 진입 전 비밀번호 검증: POST /api/app/mypage/parent/{userId}/verify-password (204)
  static Future<void> verifyParentPassword(String userId, String currentPassword) async {
    final uri = Uri.parse('$baseUrl/api/app/mypage/parent/$userId/verify-password');
    final res = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'currentPassword': currentPassword}),
    );

    // ignore: avoid_print
    print('[POST verify-password] ${res.statusCode}');

    if (res.statusCode == 204) return;
    if (res.statusCode == 401) throw Exception('비밀번호가 올바르지 않습니다.');
    if (res.statusCode == 404) throw Exception('사용자를 찾을 수 없습니다.');
    throw Exception('비밀번호 확인 실패: ${res.statusCode} ${res.body}');
  }

  // 프로필 수정: PATCH /api/app/mypage/parent/{userId}
  static Future<ParentProfile> updateParentProfile({
    required String userId,
    required String userEmail,
    required String userPhoneNum,
    String? newPassword,
    String? newPasswordConfirm,
  }) async {
    final uri = Uri.parse('$baseUrl/api/app/mypage/parent/$userId');
    final payload = {
      'userEmail': userEmail,
      'userPhoneNum': userPhoneNum,
      // 둘 다 있을 때만 포함
      if ((newPassword ?? '').isNotEmpty || (newPasswordConfirm ?? '').isNotEmpty)
        'newPassword': newPassword,
      if ((newPassword ?? '').isNotEmpty || (newPasswordConfirm ?? '').isNotEmpty)
        'newPasswordConfirm': newPasswordConfirm,
    };

    final res = await _client.patch(
      uri,
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(payload),
    );

    // ignore: avoid_print
    print('[PATCH profile] ${res.statusCode}');

    if (res.statusCode == 200) {
      return ParentProfile.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 400) throw Exception('요청 형식이 올바르지 않습니다.');
    if (res.statusCode == 401) throw Exception('인증이 필요합니다.');
    if (res.statusCode == 404) throw Exception('사용자를 찾을 수 없습니다.');
    if (res.statusCode == 409) throw Exception('이미 사용 중인 이메일입니다.');
    throw Exception('프로필 수정 실패: ${res.statusCode} ${res.body}');
  }
  // 부모 설정 조회: GET /api/app/mypage/parent/{userId}/settings
  static Future<ParentSettings> fetchSettings(String userId) async {
    final uri = Uri.parse('$baseUrl/api/app/mypage/parent/$userId/settings');
    final res = await _client.get(uri, headers: const {'Accept': 'application/json'});

    print('[GET settings/$userId] ${res.statusCode}');

    if (res.statusCode == 200) {
      return ParentSettings.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 401) {
      throw Exception('설정 조회 실패(401): 로그인 토큰을 확인해주세요.');
    }
    throw Exception('설정 조회 실패: ${res.statusCode} ${res.body}');
  }

  // 부모 설정 수정: PATCH /api/app/mypage/parent/{userId}/settings
  static Future<ParentSettings> updateSettings({
    required String userId,
    required bool allowNotifications,
    required bool emailSubscription,
    required String userLanguage,
  }) async {
    final uri = Uri.parse('$baseUrl/api/app/mypage/parent/$userId/settings');
    final payload = {
      'allowNotifications': allowNotifications,
      'emailSubscription': emailSubscription,
      'userLanguage': userLanguage,
    };

    final res = await _client.patch(
      uri,
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(payload),
    );

    print('[PATCH settings/$userId] ${res.statusCode}');

    if (res.statusCode == 200) {
      return ParentSettings.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 401) throw Exception('인증이 필요합니다.');
    if (res.statusCode == 404) throw Exception('사용자를 찾을 수 없습니다.');
    throw Exception('설정 수정 실패: ${res.statusCode} ${res.body}');
  }


  // 부모 탈퇴 사전 검증: POST /api/app/mypage/parent/{userId}/verify-delete //changed
  static Future<void> verifyDelete(String userId, String currentPassword) async {
    final uri = Uri.parse('$baseUrl/api/app/mypage/parent/$userId/verify-delete');
    final res = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'currentPassword': currentPassword}),
    );
    print('[POST verify-delete] ${res.statusCode}');
    if (res.statusCode == 204) return;
    if (res.statusCode == 401) throw Exception('비밀번호가 올바르지 않습니다.');
    if (res.statusCode == 404) throw Exception('사용자를 찾을 수 없습니다.');
    throw Exception('탈퇴 사전검증 실패: ${res.statusCode} ${res.body}');
  }

  // 부모 탈퇴: DELETE /api/app/mypage/parent/{userId} //changed
  static Future<void> deleteParent(String userId, String currentPassword) async {
    final uri = Uri.parse('$baseUrl/api/app/mypage/parent/$userId');
    final res = await _client.delete(
      uri,
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'currentPassword': currentPassword}),
    );
    print('[DELETE parent] ${res.statusCode}');
    if (res.statusCode == 204) return;
    if (res.statusCode == 401) throw Exception('비밀번호가 올바르지 않습니다.');
    if (res.statusCode == 404) throw Exception('사용자를 찾을 수 없습니다.');
    throw Exception('부모 탈퇴 실패: ${res.statusCode} ${res.body}');
  }

  // 로그아웃: POST /api/users/logout //changed
  static Future<void> logout() async {
    final uri = Uri.parse('$baseUrl/api/users/logout');
    final res = await _client.post(uri, headers: const {'Accept': 'application/json'});
    print('[POST logout] ${res.statusCode}');
    if (res.statusCode == 204) return;
    throw Exception('로그아웃 실패: ${res.statusCode} ${res.body}');
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

  String get displayNickname =>
      (childNickname != null && childNickname!.trim().isNotEmpty)
          ? childNickname!
          : childName;

  String get ageLabel => (childAge == null) ? '' : '${childAge}세';

}

// --- 모델: 부모 프로필 응답 ---
class ParentProfile {
  final String userId;
  final String userName;
  final String? userEmail;
  final String? userPhoneNum;

  ParentProfile({
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userPhoneNum,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> j) => ParentProfile(
        userId: (j['userId'] ?? '').toString(),
        userName: (j['userName'] ?? '').toString(),
        userEmail: j['userEmail']?.toString(),
        userPhoneNum: j['userPhoneNum']?.toString(),
      );
}
// 부모 설정 응답 모댈
class ParentSettings {
  final bool allowNotifications;
  final bool emailSubscription;
  final String userLanguage;

  ParentSettings({
    required this.allowNotifications,
    required this.emailSubscription,
    required this.userLanguage,
  });

  factory ParentSettings.fromJson(Map<String, dynamic> j) => ParentSettings(
        allowNotifications: j['allowNotifications'] == true,
        emailSubscription: j['emailSubscription'] == true,
        userLanguage: (j['userLanguage'] ?? 'Korea').toString(),
      );

  Map<String, dynamic> toJson() => {
        'allowNotifications': allowNotifications,
        'emailSubscription': emailSubscription,
        'userLanguage': userLanguage,
      };
}


  

