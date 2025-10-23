// lib/main/studyView/listenStudy/page/level1/animals/animal_story_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sinabro/main/studyView/listenStudy/page/level1/animals/data/animal_study_models.dart';

class AnimalStoryPage extends StatefulWidget {
  const AnimalStoryPage({
    super.key,
    required this.animalData,
    required this.onStoryCompleted,
    required this.childId,
  });

  final AnimalContentData animalData;
  final VoidCallback onStoryCompleted;
  final String childId;

  @override
  State<AnimalStoryPage> createState() => _AnimalStoryPageState();
}

class _AnimalStoryPageState extends State<AnimalStoryPage> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.animalData.storyImages.isNotEmpty) {
        precacheImage(AssetImage(widget.animalData.storyImages.first), context);
      }
      _playCurrent();
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _playCurrent() async {
    _playerSub?.cancel();
    try {
      await _player.setAsset(widget.animalData.storyAudios[_index]);
      await _player.play();
    } catch (e) {
      debugPrint('${widget.animalData.name} Story audio error: $e');
    }

    if (mounted && _index + 1 < widget.animalData.storyImages.length) {
      precacheImage(
          AssetImage(widget.animalData.storyImages[_index + 1]), context);
    }

    _playerSub = _player.playerStateStream.listen((s) async {
      if (s.processingState == ProcessingState.completed) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _next();
      }
    });
  }

  void _next() {
    if (_index < widget.animalData.storyImages.length - 1) {
      setState(() => _index++);
      _playCurrent();
    } else {
      widget.onStoryCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim),
                child: child,
              ),
            ),
            child: Image.asset(
              widget.animalData.storyImages[_index],
              key: ValueKey(widget.animalData.storyImages[_index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: _next),
          ),
        ),
      ],
    );
  }
}
