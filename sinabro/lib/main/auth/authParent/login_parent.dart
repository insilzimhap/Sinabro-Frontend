/**
 * @file lib/login/login_parent.dart
 * 역할: 부모 로그인/소셜 로그인. 로그인 성공 시 JWT를 ChildrenState에 저장.
 * @채영: JWT+api 연결 완료
 */
///


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // PlatformException
import 'package:sinabro/login/kakao_login_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sinabro/login/signup_page.dart';
import 'package:sinabro/config.dart';
import 'package:sinabro/login/social_info_page.dart';
import 'package:sinabro/common/auth_client.dart';

// ✅ 세션
import 'package:sinabro/main/parentView/page/child/children_state.dart';


// (선택) 공지로 가는 버튼 유지
import 'package:sinabro/main/parentView/page/notice/notice_page.dart' show NoticePage;

class LoginParentScreen extends StatefulWidget {
  // ⛏️ 변경: role 필요 없음 (소셜은 무조건 부모)
  const LoginParentScreen({super.key});

  @override
  State<LoginParentScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginParentScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  String _message = '';
  bool _isLoading = false;

  // ---------------- 일반 로그인 ----------------
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
        final client = AuthClient();
        final bodyOut = {
          'userId': _userIdController.text.trim(),
          'userPw': _passwordController.text.trim(),
          'role': 'parent', // 부모 고정
        };
        print('[로그인] 요청 보냄: /api/users/login (userId=${bodyOut['userId']})');

        final response = await client.post(
          Uri.parse('$baseUrl/api/users/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(bodyOut),
        );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = _safeJson(response.body);

        // 🔐 토큰 파싱
        final at = (body['accessToken'] ?? body['token']) as String?;
        final rt = body['refreshToken'] as String?;

        // 👤 사용자 정보
        final Map<String, dynamic>? u =
            (body['user'] is Map) ? body['user'] as Map<String, dynamic> : null;

        
        // 🔐 토큰 저장 (전역 + UI 스토어)
        if (at != null && at.isNotEmpty) {
          // ✅ 전역 AuthClient에도 주입 → 이후 보호 API 자동 부착
          await AuthClient.instance.setAuthToken(at, refreshToken: rt);
          await ChildrenState.instance.setToken(
            accessToken: at,
            refreshToken: (rt != null && rt.isNotEmpty) ? rt : null,
          );
          print('[로그인] 토큰 저장 완료 (AT=${at.length}자, RT=${rt != null ? '있음' : '없음'})');
        } else {
          print('[로그인][경고] 응답에 토큰이 없음');
        }
        

        // 세션 저장용 ID/이름 파싱(최상위 → user{} → 입력값 순서로 폴백)
        final parentUserId =
            (body['userId'] ?? u?['userId'] ?? _userIdController.text.trim()).toString();
        final parentUserName =
            (body['userName'] ?? u?['userName'] ?? body['name'] ?? '').toString();

        await ChildrenState.instance.setSession(
          userId: parentUserId,
          userName: parentUserName.isEmpty ? null : parentUserName,
        );
        print('[로그인] 세션 저장 완료 (userId=$parentUserId, userName=$parentUserName)');


        // 현재 코드는 공지 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NoticePage(
              parentUserId: parentUserId,
              parentDisplayName: parentUserName,
            ),
          ),
        );
      } else {
        final body = _safeJson(response.body);
        setState(() {
          _message = (body['message'] as String?) ??
              '로그인 실패: 아이디 또는 비밀번호를 확인하세요. (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _message = '에러 발생: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- 카카오 로그인 (role=parent 고정) ----------------
  Future<void> _loginWithKakao() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final user = await KakaoLoginApi.kakaoLogin();
      if (user == null) {
        setState(() {
          _message = '카카오 로그인 실패';
        });
        print('[카카오] 네이티브 로그인 실패(null)');
        return;
      }

      // 키 유지
      final nickname = user['nickname'] ?? '카카오사용자';
      final email = user['email'] ?? '';
      final kakaoId = (user['id'] ?? '').toString();

      final client = AuthClient(); // skip 대상

      final response = await client.post(
        Uri.parse('$baseUrl/api/users/social-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': kakaoId,
          'userEmail': email,
          //'userPw': kakaoId,  제거! social-register는 이제 여기서 비번 안 보내고 추가정보 패이지에서 보냄
          'userName': nickname,
          'socialType': 'kakao',
          'socialId': kakaoId,
          'role': 'parent',    // 부모 고정 
        }),
      );

      if (response.statusCode == 200) {
        // 서버 응답 형식: { user: {...}, token: '...' }
        final body = _safeJson(response.body);
        final Map<String, dynamic>? u =
            (body['user'] is Map) ? body['user'] as Map<String, dynamic> : null;

        // 🔐 토큰 키 파싱
        final at = (body['accessToken'] ?? body['token']) as String?;
        final rt = body['refreshToken'] as String?;

        if (at != null && at.isNotEmpty) {
          await AuthClient.instance.setAuthToken(at, refreshToken: rt);
          await ChildrenState.instance.setToken(
            accessToken: at,
            refreshToken: (rt != null && rt.isNotEmpty) ? rt : null,
          );
          print('[카카오] 토큰 저장 완료 (AT=${at.length}자, RT=${rt != null ? '있음' : '없음'})');
        } else {
          print('[카카오][경고] 응답에 토큰이 없음');
        }

        // 👤 세션 저장 (user{} 우선)
        final parentUserId = (u?['userId'] ?? kakaoId).toString();
        final parentUserName = (u?['userName'] ?? nickname).toString();
        await ChildrenState.instance.setSession(
          userId: parentUserId,
          userName: parentUserName.isEmpty ? null : parentUserName,
        );
        print('[카카오] 세션 저장 완료 (userId=$parentUserId, userName=$parentUserName)');

        // 정상 흐름: 공지/홈으로
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NoticePage(
              parentUserId: parentUserId,
              parentDisplayName: parentUserName,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        // ✅ 신규이며 비밀번호 미제공 등으로 400인 케이스 → 추가정보 화면으로 유도
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SocialExtraInfoPage(
              userId: kakaoId,
              userEmail: email,
              userName: nickname,
              socialType: 'kakao',
              socialId: kakaoId,
            ),
          ),
        );
      } else if (response.statusCode == 409) {
        // ✅ 기존 계정에 비번 payload를 보냈을 때만 나오는 케이스(현재 흐름에선 거의 발생 X)
        setState(() {
          _message = '이미 비밀번호가 설정된 계정입니다. (409)';
        });
      } else {
        setState(() {
          _message = '서버 오류: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '카카오 로그인 에러: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- 구글 로그인 (role=parent 고정) ----------------
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => _message = '구글 로그인 취소됨');
        return;
      }

      final name = googleUser.displayName ?? '구글사용자';
      final email = googleUser.email;
      final id = googleUser.id;

      final client = AuthClient(); // skip 대상
      final response = await client.post(
        Uri.parse('$baseUrl/api/users/social-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': id,
          'userEmail': email,
          //'userPw': id,      제거!! 여기서는 비밀번호 안 보냄
          'userName': name,
          'socialType': 'google',
          'socialId': id,
          'role': 'parent',  // 부모 고정
        }),
      );
      print('[구글] 응답 수신: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ✅ 서버 응답 형식: { user: {...}, token: '...' }
        final body = _safeJson(response.body);
        final Map<String, dynamic>? u =
            (body['user'] is Map) ? body['user'] as Map<String, dynamic> : null;

        // 🔐 토큰 키 호환: accessToken 또는 token 모두 수용(현재는 token이 표준)
        final at = (body['accessToken'] ?? body['token']) as String?;
        final rt = body['refreshToken'] as String?;

        if (at != null && at.isNotEmpty) {
          await ChildrenState.instance.setToken(
            accessToken: at,
            refreshToken: (rt != null && rt.isNotEmpty) ? rt : null,
          );
          // ignore: avoid_print
          print('[구글] 토큰 저장 완료 (AT=${at.length}자, RT=${rt != null ? '있음' : '없음'})');
        } else {
          print('[구글][경고] 응답에 토큰이 없음');
        }
        
        // 👤 세션 저장
        final parentUserId = (u?['userId'] ?? id).toString();
        final parentUserName = (u?['userName'] ?? name).toString();
        await ChildrenState.instance.setSession(
          userId: parentUserId,
          userName: parentUserName.isEmpty ? null : parentUserName,
        );
        print('[구글] 세션 저장 완료 (userId=$parentUserId, userName=$parentUserName)');

        // ✅ 정상 흐름: 공지/홈으로
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NoticePage(
              parentUserId: parentUserId,
              parentDisplayName: parentUserName,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        // ✅ 신규 + 비밀번호 미제공 등 → 추가정보 화면으로 유도
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SocialExtraInfoPage(
              userId: id,
              userEmail: email,
              userName: name,
              socialType: 'google',
              socialId: id,
            ),
          ),
        );
      } else if (response.statusCode == 409) {
        // ✅ 지금 흐름에선 발생 안 함(비번 안 보냄). 메시지만 표기.
        setState(() {
          _message = '이미 비밀번호가 설정된 계정입니다. (409)';
        });
      } else {
        setState(() => _message = '구글 로그인 실패: ${response.statusCode}');
      }
    } on PlatformException catch (e) {
      // 여기서 에러 메시지를 보기 좋게 세팅
      final code = e.code;           // 예: network_error
      final msg = e.message ?? '';
      final details = e.details;     // null 일 수 있음

      setState(() {
        _message = code == 'network_error'
            ? '구글 로그인 네트워크 오류입니다.\n'
              '· 에뮬레이터가 Google Play 이미지인지 확인\n'
              '· Play 서비스/스토어 업데이트\n'
              '· VPN/사내망 차단 여부 확인'
            : '구글 로그인 에러($code) $msg ${details ?? ''}';
      });
    } catch (e, st) {
      // 그 외 모든 예외
      setState(() => _message = '구글 로그인 에러: $e');
      debugPrint('google sign-in error: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- Helpers ----------------
  Map<String, dynamic> _safeJson(String s) {
    try {
      final v = json.decode(s);
      return (v is Map<String, dynamic>) ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }


  // ---------------- UI ----------------
  // (선택) 하단 공지 버튼
  void _goNotice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoticePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFEEFEF);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: bg, elevation: 0, toolbarHeight: 0),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight - 60),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5A4032),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _twoCardsRow(),
                        const SizedBox(height: 16),
                        if (_message.isNotEmpty)
                          Text(
                            _message,
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: TextButton.icon(
              onPressed: _goNotice,
              icon: const Icon(Icons.campaign, size: 16),
              label: const Text('공지사항으로', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoCardsRow() {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 900;
        double cardW = isNarrow ? (c.maxWidth - 32) : (c.maxWidth * 0.42);
        cardW = cardW.clamp(420.0, 620.0);

        return Flex(
          direction: isNarrow ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LoginCard(
              width: cardW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle('아이디로 로그인', underline: true),
                  const SizedBox(height: 16),
                  const _FieldLabel('아이디'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _userIdController,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('비밀번호'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(role: 'parent'),
                            ),
                          ),
                          child: const Text(
                            '계정이 없으신가요?',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF5A4032),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB9B9),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('로그인'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(width: isNarrow ? 0 : 40, height: isNarrow ? 20 : 0),
            _LoginCard(
              width: cardW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CardTitle('SNS 로그인'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loginWithKakao,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        '카카오로 로그인',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset(
                        'assets/img/auth/google_logo.jpg',
                        width: 18,
                        height: 18,
                      ),
                      label: const Text('구글로 로그인'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static InputDecoration _inputDecoration() => const InputDecoration(
        filled: true,
        fillColor: Color(0xFFF8F7F6),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE5E2E0)),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );
}

class _LoginCard extends StatelessWidget {
  final Widget child;
  final double? width;
  const _LoginCard({required this.child, this.width});
  @override
  Widget build(BuildContext context) => Container(
        width: width ?? 360,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );
}

class _CardTitle extends StatelessWidget {
  final String text;
  final bool underline;
  const _CardTitle(this.text, {this.underline = false});
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF5A4032),
          decoration: underline ? TextDecoration.underline : TextDecoration.none,
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF5A4032)),
      );
}
