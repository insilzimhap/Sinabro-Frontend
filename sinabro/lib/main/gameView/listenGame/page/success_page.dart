// lib/main/studyView/listenGame/page/levelX/result/success_page.dart
import 'package:flutter/material.dart';
import '../../common/widget/clear_popup.dart';

// 🔹 각 레벨의 테마 선택 페이지 import
import '../page/level1/level1_theme_select.dart';
import '../page/level2/level2_theme_select.dart';
import '../page/level3/level3_theme_select.dart';

class ListenGameSuccessPage extends StatefulWidget {
  final int level;
  const ListenGameSuccessPage({super.key, required this.level});

  @override
  State<ListenGameSuccessPage> createState() => _ListenGameSuccessPageState();
}

class _ListenGameSuccessPageState extends State<ListenGameSuccessPage> {
  @override
  void initState() {
    super.initState();
    _showPopupAndNavigate();
  }

  Future<void> _showPopupAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // ✅ 레벨에 따라 이동할 테마 선택 페이지 지정
    Widget themePage;
    switch (widget.level) {
      case 1:
        themePage = const Level1ThemeSelectPage();
        break;
      case 2:
        themePage = const Level2ThemeSelectPage();
        break;
      case 3:
        themePage = const Level3ThemeSelectPage();
        break;
      default:
        break;
    }

    // 🎉 클리어 팝업 띄우기
    await showClearPopup(context, themePage);
  }

  @override
  Widget build(BuildContext context) {
    final imagePath =
        'assets/img/contents/listenGame/level${widget.level}/result/success.jpg';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
