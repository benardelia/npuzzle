import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:npuzzle/levels.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  await Hive.initFlutter();
  var box = await Hive.openBox('Level');

  if (box.isEmpty) {
    await box.put('val', 0);
    await box.put('color', const Color(0xffa5773b).value);
  }

  runApp(const PlayGroung());
}

class PlayGroung extends StatefulWidget {
  const PlayGroung({super.key});

  static late Color mainColor;

  @override
  State<PlayGroung> createState() => _PlayGroungState();
}

class _PlayGroungState extends State<PlayGroung> {
  bool isDark = false;
  void changeMode(bool val) {
    setState(() {
      isDark = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          brightness: isDark ? Brightness.dark : Brightness.light),
      debugShowCheckedModeBanner: false,
      home: Levels(
        changeMode: changeMode,
        darkMode: isDark,
      ),
    );
  }
}
