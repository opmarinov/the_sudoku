import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'game_screen.dart';
import 'level_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashScreenStateWidget();
}

class _SplashScreenStateWidget extends State<SplashScreen> {
  _redirectScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LevelScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250.0,
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 30.0,
            fontFamily: 'Agne',
          ),
          child: AnimatedTextKit(
            totalRepeatCount: 1,
            animatedTexts: [
              TypewriterAnimatedText('You are playing'),
              TypewriterAnimatedText('The Sudoku'),
            ],
            onFinished: () {
              _redirectScreen();
            },
          ),
        ),
      ),
    );
  }
}
