import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';

class GameOverAlert extends StatelessWidget {
  const GameOverAlert(
      {super.key,
      this.onNegativeAction,
      this.onPositiveAction,
      this.message,
      this.title,
      this.positiveActionText,
      this.negativeActionText,
      this.messageSize});
  final void Function()? onNegativeAction;
  final void Function()? onPositiveAction;
  final String? message;
  final String? title;
  final String? positiveActionText;
  final String? negativeActionText;
  final double? messageSize;

  @override
  Widget build(BuildContext context) {
    AppController appController = Get.find<AppController>();
    var style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 25,
      color: appController.appColor.value,
      decoration: TextDecoration.none,
    );

    var buttonStyle = TextButton.styleFrom(
        backgroundColor: appController.appColor.value,
        foregroundColor: Colors.white);
    return AlertDialog(
      
      content: SizedBox(
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            Text(title ?? 'Game Over', style: style),
            Text(
              message ??
                  'You have run out of time. \n Do you want to add more time or restart the game?',
              style: style.copyWith(fontSize: messageSize ?? 30),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: onNegativeAction,
            style: buttonStyle,
            child: Text(
              negativeActionText ?? 'Restart',
              style: TextStyle(fontSize: 12),
            )),
        TextButton(
            onPressed: onPositiveAction,
            style: buttonStyle,
            child: Text(
              positiveActionText ?? 'Add Time',
              style: TextStyle(fontSize: 12),
            )),
      ],
    );
  }
}
