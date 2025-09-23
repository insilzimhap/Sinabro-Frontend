/*
 * 파일: lib/main/parentView/page/notice_page.dart (NoticePage)
 * @ authoor 박성민
 * 개요: 부모용 공지사항 목록 화면. ParentLayout 하위에서 공지 리스트를
 *      펼침/접힘 UI로 보여준다. 세션/부모정보를 복구해 사이드바/헤더에 반영.
 *      - 리스트: GET /api/app/notices?page=0&size=20
 *      - 상세:   GET /api/app/notices/{id}?increaseView=true (펼칠 때 로드)
 *      - JWT 필요 없음(permitAll). 헤더/사이드바용 부모표기는 기존 ChildrenState/ParentApi 흐름 유지.
 * @ 채영: JWT+api 연결 완료
 */
import 'package:flutter/material.dart';
import 'package:sinabro/main/parentView/layout/parent_layout.dart';
import 'package:sinabro/main/parentView/api/parent_api.dart' as parent_api;
import 'package:sinabro/main/parentView/page/children_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sinabro/config.dart';

// 리스트 아이템(본문 제외)
class NoticeRow {
  final int id;
  final String title;
  final String author;
  final DateTime createdAt;
  final int views;
  final bool urgent;
  const NoticeRow({
    required this.id,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.views,
    required this.urgent,
  });

  factory NoticeRow.fromJson(Map<String, dynamic> j) {
    // 서버 포맷: createdAt 예) "2025-08-17 00:15"
    final createdStr = (j['createdAt'] ?? '').toString();
    DateTime created;
    try {
      created = DateTime.parse(createdStr.replaceFirst(' ', 'T'));
    } catch (_) {
      created = DateTime.now();
    }
    return NoticeRow(
      id: (j['id'] as num).toInt(),
      title: j['title']?.toString() ?? '',
      author: j['author']?.toString() ?? '팀 시나브로',
      createdAt: created,
      views: (j['viewCount'] is num) ? (j['viewCount'] as num).toInt() : 0,
      urgent: j['urgent'] == true,
    );
  }
}



// 상세(본문 포함)
class NoticeDetail {
  final int id;
  final String content;
  final int views; // 서버가 증가된 조회수 내려줌
  const NoticeDetail({required this.id, required this.content, required this.views});
  factory NoticeDetail.fromJson(Map<String, dynamic> j) => NoticeDetail(
        id: (j['id'] as num).toInt(),
        content: j['content']?.toString() ?? '',
        views: (j['viewCount'] is num) ? (j['viewCount'] as num).toInt() : 0,
      );
}



class NoticePage extends StatefulWidget {
  final String? parentUserId; // (선택) 상단 컨텍스트 표기에 사용
  final String? parentDisplayName; // (선택)
  const NoticePage({super.key, this.parentUserId, this.parentDisplayName});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  // ---------------- 상태/세션 ----------------
  final _store = ChildrenState.instance;
  bool _ready = false;
  String? _err;
  String _uid = '';
  String _parentName = '';
  bool _authWarn = false; // JWT 만료/없음 → 배너 노출

  // ---------------- 리스트 상태 ----------------
  final List<NoticeRow> _rows = [];
  final Map<int, NoticeDetail> _detailCache = {}; // id → 상세 캐시(펼칠 때 로드)
  int _page = 0;
  final int _size = 20;
  bool _hasNext = true;
  bool _isLoadingList = false;
  int _openIndex = -1; // 펼친 행 인덱스(없으면 -1)
  int? _loadingDetailId; // 상세 로딩 표시용

  // ---------------- 초기 진입 ----------------
  @override
  void initState() {
    super.initState();
    _ensureParentContext();
  }

  Future<void> _ensureParentContext() async {
    setState(() {
      _ready = false;
      _err = null;
    });

    try {
      // 부모 컨텍스트(사이드바/헤더용) 복구
      // 1) userId 결정 (prop → active → session → prefs)
      await _store.setParent(widget.parentUserId);
      final uid = (_store.activeUserId ?? '').trim();
      if (uid.isEmpty) {
        throw 'parentUserId가 없습니다. 로그인/세션을 확인해주세요.';
      }

      // 2) 이름 결정 (prop → session → 서버)
      var name = (widget.parentDisplayName ?? '').trim();
      if (name.isEmpty) name = (_store.sessionUserName ?? '').trim();
      if (name.isEmpty) {
        try {
          name = await parent_api.ParentApi.fetchParentName(uid); // 🔐 JWT 필요
          await _store.setSession(userId: uid, userName: name);
        } catch (e) {
        // ✅ 이전처럼 _err로 막지 말고, 배너만 띄움
        if (mounted) setState(() => _authWarn = true);
        name = ''; // 이름은 비워두고 아래에서 기본 표시 처리
      }
    }

      // 공지 첫 페이지 로드
      await _loadFirstPage();

      if (!mounted) return;
      setState(() {
        _uid = uid;
        _parentName = name.isEmpty ? '부모' : name;
        _ready = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = '서버 연결 실패: $e';
        _ready = false;
      });
    }
  }

  // ---------------- API ----------------

  /// 리스트 1페이지부터 다시 로드
  Future<void> _loadFirstPage() async {
    _rows.clear();
    _page = 0;
    _hasNext = true;
    _openIndex = -1;
    await _loadMore();
  }

  /// 페이지네이션 추가 로드 (permitAll → http 사용)
  Future<void> _loadMore() async {
    if (_isLoadingList || !_hasNext) return;
    setState(() => _isLoadingList = true);

    final uri = Uri.parse('$baseUrl/api/app/notices')
        .replace(queryParameters: {'page': '$_page', 'size': '$_size'});

    try {
      // ignore: avoid_print
      print('[notice] 공지 리스트 요청: page=$_page size=$_size');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        // ignore: avoid_print
        print('[notice][오류] 리스트 응답 상태코드=${resp.statusCode}');
        throw '공지 리스트 로드 실패(${resp.statusCode})';
      }

      final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
      final List list = (jsonMap['content'] as List?) ?? const [];
      final rows = list
          .whereType<Map<String, dynamic>>()
          .map(NoticeRow.fromJson)
          .toList();

      setState(() {
        _rows.addAll(rows);
        _hasNext = jsonMap['hasNext'] == true;
        _page = _page + 1;
      });

      // ignore: avoid_print
      print('[notice] 리스트 로드 완료: 추가=${rows.length} 총=${_rows.length} hasNext=$_hasNext');
    } catch (e) {
      if (!mounted) return;
      setState(() => _err = '공지 리스트 로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoadingList = false);
    }
  }

  /// 상세 로드(펼칠 때). 서버가 기본 increaseView=true이므로 조회수도 증가.
  Future<NoticeDetail?> _loadDetail(int id) async {
    if (_detailCache.containsKey(id)) return _detailCache[id];

    final uri = Uri.parse('$baseUrl/api/app/notices/$id')
        .replace(queryParameters: {'increaseView': 'true'});

    try {
      // ignore: avoid_print
      print('[notice] 상세 요청: id=$id (조회수 증가)');
      setState(() => _loadingDetailId = id);

      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        // ignore: avoid_print
        print('[notice][오류] 상세 응답 상태코드=${resp.statusCode}');
        return null;
      }
      final map = json.decode(resp.body) as Map<String, dynamic>;
      final detail = NoticeDetail.fromJson(map);
      _detailCache[id] = detail;

      // 리스트의 해당 항목 view 수 갱신(가능하면)
      final idx = _rows.indexWhere((r) => r.id == id);
      if (idx != -1) {
        final r = _rows[idx];
        _rows[idx] = NoticeRow(
          id: r.id,
          title: r.title,
          author: r.author,
          createdAt: r.createdAt,
          views: detail.views,
          urgent: r.urgent,
        );
      }

      // ignore: avoid_print
      print('[notice] 상세 로드 완료: id=$id views=${detail.views}');
      return detail;
    } catch (e) {
      // ignore: avoid_print
      print('[notice][오류] 상세 로드 실패: $e');
      return null;
    } finally {
      if (mounted) setState(() => _loadingDetailId = null);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (_err != null) {
      return ParentLayout(
        activeMenu: '공지사항',
        parentUserId: _uid,
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _ensureParentContext,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ParentLayout(
      activeMenu: '공지사항',
      parentUserId: _uid,
      content: Container(
        color: const Color(0xFFF9F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  const _NoticeHeader(),
                  if (_authWarn)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFEEBA)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, size: 18, color: Color(0xFF856404)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '로그인을 진행해주세요!',
                              style: TextStyle(fontSize: 13, color: Color(0xFF856404)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
                          _loadMore();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        itemCount: _rows.length + (_hasNext ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          // 맨 아래 로딩 셀
                          if (i >= _rows.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final item = _rows[i];
                          final opened = _openIndex == i;
                          final detail = _detailCache[item.id];
                          final isLoadingDetail = _loadingDetailId == item.id;

                          return _NoticeTile(
                            item: item,
                            opened: opened,
                            detailText: opened
                                ? (detail?.content ?? (isLoadingDetail ? '불러오는 중...' : '탭하여 본문 불러오기'))
                                : null,
                            onTap: () async {
                              if (_openIndex == i) {
                                setState(() => _openIndex = -1);
                                return;
                              }
                              // 🔽 매번 펼칠 때 조회수 올리기: 캐시 제거해서 재요청 유도
                              _detailCache.remove(item.id);

                              // 펼칠 때 상세 없으면 로드
                              if (_loadingDetailId == item.id) return; // 중복 탭 방지(선택)
                              final ok = await _loadDetail(item.id);   // increaseView=true 이므로 +1
                              if (ok == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('공지 상세를 불러오지 못했습니다.')),
                                );
                                return;
                              }
            
                              if (!mounted) return;
                              setState(() => _openIndex = i);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeHeader extends StatelessWidget {
  const _NoticeHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF6DBF73),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: const [
          SizedBox(width: 12),
          Icon(Icons.home, color: Colors.white),
          SizedBox(width: 12),
          Text(
            '공지사항',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  final NoticeRow item;
  final bool opened;
  final String? detailText; // 펼쳤을 때만 표시
  final VoidCallback onTap;
  const _NoticeTile({
    required this.item,
    required this.opened,
    required this.detailText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: const Color(0xFFE6E6E6));
    final dateStr =
        '${item.createdAt.year.toString().padLeft(4, '0')}-'
        '${item.createdAt.month.toString().padLeft(2, '0')}-'
        '${item.createdAt.day.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: border,
            boxShadow: opened
                ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    const _RoundIcon(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(opened ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black45),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 4),
                child: Row(
                  children: [
                    Text(item.author, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 12),
                    Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    const SizedBox(width: 12),
                    Text('조회: ${item.views}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ),
              ClipRect(
                child: AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(44, 10, 12, 16),
                    child: Text(detailText ?? '', style: const TextStyle(fontSize: 14, height: 1.5)),
                  ),
                  crossFadeState: opened ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 180),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  class _RoundIcon extends StatelessWidget {
    const _RoundIcon();
    @override
    Widget build(BuildContext context) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.campaign_outlined,
          size: 14,
          color: Colors.black54,
        ),
      );
    }
  }