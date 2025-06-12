import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:npuzzle/main.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';

// ignore: must_be_immutable
class PickColors extends StatelessWidget {
  PickColors({super.key});
  Color selectedColor = PlayGroung.mainColor;
  var box = Hive.box('Level');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customize Color'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: selectedColor,
          onColorChanged: (value) {
            selectedColor = value;
          },
          paletteType: PaletteType.hueWheel,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () async {
             var appController = Get.find<AppController>();
             appController.appColor.value = selectedColor;
              Navigator.pop(context);
              await box.put('color', selectedColor.value);
            },
            child: const Text('Save')),
      ],
    );
  }
}
