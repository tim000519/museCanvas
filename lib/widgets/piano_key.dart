import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../services/audio_cache.dart';

class PianoKey extends StatefulWidget {
  final String note; // 예: 'C4'
  final VoidCallback onPress;
  final VoidCallback onRelease;
  final bool isBlack;

  const PianoKey({
    Key? key,
    required this.note,
    required this.onPress,
    required this.onRelease,
    this.isBlack = false,
  }) : super(key: key);

  @override
  State<PianoKey> createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  late html.AudioElement _audio;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();

    // 오디오 미리 생성 (캐시됨)
    _audio = html.AudioElement('sounds/${widget.note}.mp3')
      ..preload = 'auto'
      ..load();
  }

  void playSound() {
    playCachedNote(widget.note);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
        widget.onPress();
        playSound();
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.onRelease();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
        widget.onRelease();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: isPressed
            ? Matrix4.translationValues(0, 5, 0)
            : Matrix4.identity(),
        width: widget.isBlack ? 30 : 50,
        height: widget.isBlack ? 100 : 150,
        margin: widget.isBlack
            ? const EdgeInsets.symmetric(horizontal: 5)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isPressed
              ? const Color.fromRGBO(155, 62, 51, 1)
              : (widget.isBlack
                  ? Colors.black
                  : const Color.fromARGB(255, 255, 251, 231)),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
          boxShadow: isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(2, 4),
                    blurRadius: 4,
                  ),
                ],
        ),
      ),
    );
  }
}
