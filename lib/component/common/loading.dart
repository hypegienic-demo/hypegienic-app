import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoadingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        'LOADING',
        "Don't panic",
        "It's almost done"
      ].map((text) =>
        ShufflingLetterAnimatedText(text,
          textStyle: Theme.of(context).textTheme.headline5
        )
      ).toList(),
      pause: Duration(seconds:1),
      repeatForever: true
    );
  }
}

class _ShufflingLetter {
  String? current;
  String from;
  String to;
  double start;
  double end;
  _ShufflingLetter({
    this.current,
    required this.from,
    required this.to,
    required this.start,
    required this.end
  });
}
final _shufflingCharacters = '!<>-_\\/[]{}—=+*^?#________';
class ShufflingLetterAnimatedText extends AnimatedText {
  late AnimationController controller;
  final double shufflingDuration;
  final math.Random random;
  late List<_ShufflingLetter> letters;
  ShufflingLetterAnimatedText(String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle? textStyle,
    Duration duration = const Duration(seconds:5),
    Duration shufflingDuration = const Duration(seconds:1)
  }) :
    assert(duration > shufflingDuration * 2,
      'The "duration" must be at least twice the "shufflingDuration"'
    ),
    this.shufflingDuration = shufflingDuration.inMicroseconds / duration.inMicroseconds,
    this.random = math.Random(),
    super(
      text: text,
      textAlign: textAlign,
      textStyle: textStyle,
      duration: duration,
    );

  resetFrames() {
    this.letters = text
      .split('')
      .map((letter) {
        final start = random.nextDouble() * shufflingDuration / 2;
        return _ShufflingLetter(
          from: '',
          to: letter,
          start: start,
          end: start + (random.nextDouble() * shufflingDuration / 2)
        );
      })
      .toList();
  }

  @override
  void initAnimation(AnimationController controller) {
    this.controller = controller;
    this.resetFrames();
  }
  @override
  Widget completeText(BuildContext context) {
    this.resetFrames();
    return SizedBox.shrink();
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    final now = controller.value;
    this.letters = this.letters.map((letter) {
      if(now < letter.start) {
        letter.current = letter.from;
      } else if(now <= letter.end) {
        if((letter.current == letter.from || random.nextDouble() < 0.28)) {
          letter.current = _shufflingCharacters[(random.nextDouble() * _shufflingCharacters.length).floor()];
        }
      } else if(now < 1 - shufflingDuration + letter.start) {
        letter.current = letter.to;
      } else if(now <= 1 - shufflingDuration + letter.end) {
        if((letter.current == letter.to || random.nextDouble() < 0.28)) {
          letter.current = _shufflingCharacters[(random.nextDouble() * _shufflingCharacters.length).floor()];
        }
      } else {
        letter.current = letter.from;
      }
      return letter;
    }).toList();
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        children: letters.map((letter) =>
          TextSpan(
            text: letter.current,
            style: letter.current != letter.from &&
              letter.current != letter.to
              ? textStyle?.copyWith(
                  color: textStyle!.color?.withOpacity(0.3)
                )
              : textStyle
          )
        ).toList()
      )
    );
  }
}