import 'dart:async';
import 'package:flutter/material.dart';
import 'data/routine_data.dart';

class IntroPage extends StatefulWidget {
  final VoidCallback onNext;
  const IntroPage({super.key, required this.onNext});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Timer? _timer;
  bool _canTap = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _canTap = true);
    });
    _timer = Timer(const Duration(seconds: 20), () {
      if (mounted) widget.onNext();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (_canTap) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(introData.imagePath ?? "", width: 240),
              const SizedBox(height: 24),
              Text(introData.text, style: const TextStyle(fontSize: 20)),
              if (!_canTap)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text("잠시만 기다려주세요...",
                      style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
