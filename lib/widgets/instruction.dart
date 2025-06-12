import 'package:flutter/material.dart';

class Instruction extends StatelessWidget {
  const Instruction({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back'))
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
                'The objective is simple: rearrange the tiles by sliding them into the empty space until the numbers are arranged in ascending order from left to right as shown in image below.'),
            Image.asset('assets/goal.jpg')
          ],
        ),
      ),
    );
  }
}
