import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:npuzzle/main.dart';

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
              PlayGroung.mainColor = selectedColor;
              Navigator.pop(context);
              await box.put('color', selectedColor.value);
            },
            child: const Text('Save')),
      ],
    );
  }
}
