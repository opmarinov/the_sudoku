import 'package:flutter/material.dart';
import 'package:sudoku/event_colors.dart';
import 'package:sudoku/game_screen.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 3,
        children: List.generate(
          30,
          (level) {
            return InkWell(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: EventColors.BORDER_COLOR),
                ),
                child: Center(
                  child: Text(
                    'Level ${level + 1}',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      level: (level + 1).toDouble(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
