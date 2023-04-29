import 'package:flutter/material.dart';
import 'package:npuzzle/levels.dart';

void main() {
  runApp(const PlayGroung());
}

class PlayGroung extends StatefulWidget {
  const PlayGroung({super.key});

  @override
  State<PlayGroung> createState() => _PlayGroungState();
}

class _PlayGroungState extends State<PlayGroung> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Levels(),
    );
  }
}

// [3, 4, 0, 6, 1, 8, 2, 5, 7]
// [3, 4, 8, 6, 1, 0, 2, 5, 7]
// [3, 4, 8, 6, 0, 1, 2, 5, 7]
// [3, 0, 8, 6, 4, 1, 2, 5, 7]
// [0, 3, 8, 6, 4, 1, 2, 5, 7]
// [6, 3, 8, 0, 4, 1, 2, 5, 7]
// [6, 3, 8, 2, 4, 1, 0, 5, 7]
// [6, 3, 8, 2, 4, 1, 5, 0, 7]
// [6, 3, 8, 2, 0, 1, 5, 4, 7]
// [6, 3, 8, 2, 1, 0, 5, 4, 7]
// [6, 3, 0, 2, 1, 8, 5, 4, 7]
// [6, 0, 3, 2, 1, 8, 5, 4, 7]
// [6, 1, 3, 2, 0, 8, 5, 4, 7]
// [6, 1, 3, 0, 2, 8, 5, 4, 7]
// [0, 1, 3, 6, 2, 8, 5, 4, 7]
// [1, 0, 3, 6, 2, 8, 5, 4, 7]
// [1, 2, 3, 6, 0, 8, 5, 4, 7]
// [1, 2, 3, 0, 6, 8, 5, 4, 7]
// [1, 2, 3, 5, 6, 8, 0, 4, 7]
// [1, 2, 3, 5, 6, 8, 4, 0, 7]
// [1, 2, 3, 5, 6, 8, 4, 7, 0]
// [1, 2, 3, 5, 6, 0, 4, 7, 8]
// [1, 2, 3, 5, 0, 6, 4, 7, 8]
// [1, 2, 3, 0, 5, 6, 4, 7, 8]
// [1, 2, 3, 4, 5, 6, 0, 7, 8]
// [1, 2, 3, 4, 5, 6, 7, 0, 8]
// [1, 2, 3, 4, 5, 6, 7, 8, 0]