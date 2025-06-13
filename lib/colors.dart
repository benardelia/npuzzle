import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';

// ignore: must_be_immutable
class PickColors extends StatelessWidget {
  const PickColors({super.key});

  @override
  Widget build(BuildContext context) {
    var appController = Get.find<AppController>();

    return AlertDialog(
      title: const Text('Customize Color'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: appController.appColor.value,
          onColorChanged: (value) {
            appController.appColor.value = value;
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
              Navigator.pop(context);
              await appController.appBox
                  .put('color', appController.appColor.value.toARGB32());
            },
            child: const Text('Save')),
      ],
    );
  }
}
